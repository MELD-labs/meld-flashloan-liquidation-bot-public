// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {FlashLoanReceiverBase} from "./FlashLoanReceiverBase.sol";
import {IAddressesProvider} from "./interfaces/IAddressesProvider.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title LiquidateLoan
 * @author Pepe Blasco
 * @notice A contract that liquidates unhealthy loans leveraging flashloans and swaps the collateral back to the borrowed asset in a uniV2 protocol
 */
contract LiquidateLoan is FlashLoanReceiverBase, AccessControl {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IAddressesProvider public provider;
    IUniswapV2Router02 public uniswapV2Router;

    uint256 public myMinBenefit;

    address public lendingPoolAddr;

    // Will receive the benefits from liquidations
    address public treasury;

    /**
     * @notice  Event emitted when a flash loan liquidation is executed
     * @param   collateralAddress  Address of the collateral token
     * @param   debtAddress  Address of the debt token
     * @param   flashLoanAmount  Amount of the flash loan
     * @param   flashLoanPremium  Premium of the flash loan
     * @param   actualDebtCovered  Amount of the debt covered
     * @param   actualCollateralLiquidated  Amount of the collateral liquidated
     * @param   debtAssetProfit  Profit from the liquidation
     */
    event FlashLoanLiquidation(
        address indexed collateralAddress,
        address indexed debtAddress,
        uint256 flashLoanAmount,
        uint256 flashLoanPremium,
        uint256 actualDebtCovered,
        uint256 actualCollateralLiquidated,
        uint256 debtAssetProfit
    );

    constructor(
        address _protocolAddressProvider,
        address _uniswapV2Router,
        address _defaultAdmin
    ) FlashLoanReceiverBase(IAddressesProvider(_protocolAddressProvider)) {
        // require that none of the parameters are empty
        require(_protocolAddressProvider != address(0), "Invalid protocol address provider");
        require(_uniswapV2Router != address(0), "Invalid uniswap router address");
        require(_defaultAdmin != address(0), "Invalid default admin address");

        provider = IAddressesProvider(_protocolAddressProvider);
        // Automatically get the lending pool contract from the main address provider
        lendingPoolAddr = provider.getLendingPool();

        // instantiate UniswapV2 Router02
        uniswapV2Router = IUniswapV2Router02(address(_uniswapV2Router));

        myMinBenefit = 105_00; // 5% profit

        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        treasury = _defaultAdmin;
    }

    /**
     * @notice  This function is used to set the treasury address
     * @param   _treasury  Address of the treasury.
     */
    function setTreasury(address _treasury) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_treasury != address(0), "Invalid treasury address");
        treasury = _treasury;
    }

    /**
     * @notice  This function is used to set the minimum benefit that the liquidator will get from the liquidation
     * @param   _myMinBenefit  Minimum benefit that the liquidator will get from the liquidation
     */
    function setMyMinBenefit(uint256 _myMinBenefit) public onlyRole(DEFAULT_ADMIN_ROLE) {
        myMinBenefit = _myMinBenefit;
    }

    /**
     * @notice  This function is used to set the protocol address provider
     * @param   _protocolAddressProvider  Address of the protocol address provider
     */
    function setProtocolAddressProvider(
        address _protocolAddressProvider
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_protocolAddressProvider != address(0), "Invalid protocol address provider");
        provider = IAddressesProvider(_protocolAddressProvider);
        lendingPoolAddr = provider.getLendingPool();
    }

    /**
     * @notice  This function is used to set the UniswapV2Router02 address
     * @param   _uniswapV2Router  Address of the UniswapV2Router02
     */
    function setUniswapV2Router(address _uniswapV2Router) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_uniswapV2Router != address(0), "Invalid uniswap router address");
        uniswapV2Router = IUniswapV2Router02(address(_uniswapV2Router));
    }

    /**
     * @notice  This function is externally called to start the flash loan liquidation process
     * @dev     Anyone can call this function to liquidate a loan. Profit will be sent to the treasury
     * @param   _assetToLiquidate  Token address of the asset that will be liquidated
     * @param   _flashLoanAmount  Flash loan amount (number of tokens) which is exactly the amount that will be liquidated
     * @param   _collateralAsset  Token address of the collateral. This is the token that will be received after liquidating loans
     * @param   _userToLiquidate  User Address of the loan that will be liquidated
     * @param   _swapPath  path for uniV2 swap
     */
    function liquidateUserWithFlashLoan(
        address _assetToLiquidate,
        uint256 _flashLoanAmount,
        address _collateralAsset,
        address _userToLiquidate,
        address[] memory _swapPath
    ) public {
        // the asset to be flashed is the asset to be liquidated
        address[] memory assets = new address[](1);
        assets[0] = _assetToLiquidate;

        // the amount to be flashed is the amount to be liquidated
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _flashLoanAmount;

        // passing these params to executeOperation so that they can be used to liquidate the loan and perform the swap
        bytes memory params = abi.encode(_collateralAsset, _userToLiquidate, _swapPath);

        // Execute the flashloan. The flow will continue in the executeOperation function.
        ILendingPool(lendingPoolAddr).flashLoan(assets, amounts, params);
    }

    /**
     * @notice  Executes the operation on the flash loan. Automatically called by the L&B protocol after granting flash loan
     * @dev     Function name and params needs to comply with the protocol's standards. Do not change the interface
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address,
        bytes calldata params
    ) external override returns (bool) {
        // This are the params we passed into the flashloan function
        (address collateral, address userToLiquidate, address[] memory swapPath) = abi.decode(
            params,
            (address, address, address[])
        );

        // Approve tokens and liquidate unhealthy loan
        address asset = assets[0];
        uint256 amount = amounts[0];
        uint256 premium = premiums[0];

        IERC20(asset).approve(address(lendingPoolAddr), amount);

        (uint256 actualDebtCovered, uint256 actualCollateralLiquidated) = ILendingPool(
            lendingPoolAddr
        ).liquidationCall(collateral, asset, userToLiquidate, amount, false);

        //swap collateral from liquidate back to asset from flashloan to pay it off
        uint256 currentBalance = IERC20(collateral).balanceOf(address(this));
        uint256 minAmountOut = (myMinBenefit * (amount)) / 10000 + premium - currentBalance;
        swapToBorrowedAsset(collateral, minAmountOut, swapPath);

        // Calculate profit after paying back the loan and fees
        // IF NOT ENOUGH FUNDS TO REPAY THE LOAN, THE TRANSACTION WILL REVERT
        uint256 profit = IERC20(asset).balanceOf(address(this)) - amount - premium;
        require(profit > 0, "Not enough profit to repay the loan");

        // Transfer profit to treasury
        IERC20(asset).safeTransfer(treasury, profit);

        // Approve the LendingPool contract allowance to *pull* the owed amount
        IERC20(asset).approve(lendingPoolAddr, amount + premium);

        emit FlashLoanLiquidation(
            collateral,
            asset,
            amount,
            premium,
            actualDebtCovered,
            actualCollateralLiquidated,
            profit
        );

        return true;
    }

    /**
     * @notice  This function is used to swap the collateral back to the borrowed asset
     * @dev     Swaps the full amount of the token that has been liquidated
     */
    function swapToBorrowedAsset(
        address asset_from,
        uint amountOutMin,
        address[] memory swapPath
    ) public {
        IERC20 asset_fromToken = IERC20(asset_from);

        // swap full amount of current balance of the token (everything that has been liquidated)
        uint256 amountToTrade = asset_fromToken.balanceOf(address(this));

        // approve uniswap access to the token
        asset_fromToken.approve(address(uniswapV2Router), amountToTrade);

        // Execute swap from asset_from into requested ERC20 (asset_to) token
        uniswapV2Router.swapExactTokensForTokens(
            amountToTrade,
            amountOutMin,
            swapPath,
            address(this),
            block.timestamp + 300 // 5 minutes deadline
        );
    }
}
