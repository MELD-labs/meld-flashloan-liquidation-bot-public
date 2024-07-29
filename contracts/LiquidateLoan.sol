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
 * @author Pepe Blasco & MELD team
 * @notice A contract that liquidates unhealthy loans leveraging flashloans and swaps the collateral back to the borrowed asset in a uniV2 protocol
 */
contract LiquidateLoan is FlashLoanReceiverBase, AccessControl {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IAddressesProvider public provider;
    IUniswapV2Router02 public uniswapV2Router;

    uint256 public myMinBenefit; // In basis points (105_00 = 5% benefit)

    address public lendingPoolAddr;

    // Will receive the benefits from liquidations
    address public treasury;

    /**
     * @notice  Event emitted when a flash loan liquidation is executed
     * @param   collateralAddress  Address of the collateral token
     * @param   debtAddress  Address of the debt token
     * @param   liquidatedUser  Address of the user that has been liquidated
     * @param   flashLoanAmount  Amount of the flash loan
     * @param   flashLoanPremium  Premium of the flash loan
     * @param   actualDebtCovered  Amount of the debt covered
     * @param   actualCollateralLiquidated  Amount of the collateral liquidated
     * @param   debtAssetProfit  Profit from the liquidation
     */
    event FlashLoanLiquidation(
        address indexed collateralAddress,
        address indexed debtAddress,
        address indexed liquidatedUser,
        uint256 flashLoanAmount,
        uint256 flashLoanPremium,
        uint256 actualDebtCovered,
        uint256 actualCollateralLiquidated,
        uint256 debtAssetProfit
    );

    /**
     * @notice  Constructor for the LiquidateLoan contract
     * @param   _protocolAddressProvider  Address of the protocol address provider
     * @param   _uniswapV2Router  Address of the UniswapV2Router02
     * @param   _defaultAdmin  Address of the default admin
     */
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
     * @param   _myMinBenefit  Minimum benefit that the liquidator will get from the liquidation in basis points (105_00 = 5% benefit)
     */
    function setMyMinBenefit(uint256 _myMinBenefit) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_myMinBenefit > 100_00, "Invalid min benefit");
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
     * @dev     The flash loan is used to borrow the amount of the debt token to liquidate the position
     * @param   _assetToLiquidate  Token address of the asset that will be liquidated (debt token)
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
     * @param   _assets  Array of addresses of the assets that are being flashed (should include only the debt token)
     * @param   _amounts  Array of amounts of the assets that are being flashed (should include only the debt token flash loan amount)
     * @param   _premiums  Array of premiums of the assets that are being flashed (should include only the debt token premium)
     * @param   _params  Additional data that is passed to the executeOperation function (this includes the collateral, userToLiquidate and swapPath)
     */
    function executeOperation(
        address[] calldata _assets,
        uint256[] calldata _amounts,
        uint256[] calldata _premiums,
        address,
        bytes calldata _params
    ) external override returns (bool) {
        // This are the params we passed into the flashloan function
        (address collateral, address userToLiquidate, address[] memory swapPath) = abi.decode(
            _params,
            (address, address, address[])
        );

        // Approve tokens and liquidate unhealthy loan
        address debtAsset = _assets[0];
        uint256 flashLoanAmount = _amounts[0];
        uint256 flashLoanPremium = _premiums[0];

        IERC20(debtAsset).approve(address(lendingPoolAddr), flashLoanAmount);

        (uint256 actualDebtCovered, uint256 actualCollateralLiquidated) = ILendingPool(
            lendingPoolAddr
        ).liquidationCall(collateral, debtAsset, userToLiquidate, flashLoanAmount, false);

        // Swap collateral from liquidate back to the debt asset from flashloan to pay it off
        uint256 currentDebtAssetBalance = IERC20(collateral).balanceOf(address(this));
        uint256 minDebtAmountOut = (myMinBenefit * (flashLoanAmount)) /
            10000 +
            flashLoanPremium -
            currentDebtAssetBalance;
        swapToBorrowedAsset(collateral, minDebtAmountOut, swapPath);

        // Calculate profit (in debt asset) after paying back the loan and fees
        // IF NOT ENOUGH FUNDS TO REPAY THE LOAN, THE TRANSACTION WILL REVERT
        uint256 profit = IERC20(debtAsset).balanceOf(address(this)) -
            flashLoanAmount -
            flashLoanPremium;
        require(profit > 0, "Not enough profit to repay the loan");

        // Transfer profit to treasury
        IERC20(debtAsset).safeTransfer(treasury, profit);

        // Approve the LendingPool contract allowance to *pull* the owed amount
        IERC20(debtAsset).approve(lendingPoolAddr, flashLoanAmount + flashLoanPremium);

        emit FlashLoanLiquidation(
            collateral,
            debtAsset,
            userToLiquidate,
            flashLoanAmount,
            flashLoanPremium,
            actualDebtCovered,
            actualCollateralLiquidated,
            profit
        );

        return true;
    }

    /**
     * @notice  This function is used to swap the collateral back to the borrowed asset
     * @dev     Swaps the full amount of the token that has been liquidated
     * @param   _collateralAsset  Token address of the collateral
     * @param   _minDebtAmountOut  Minimum amount of the borrowed asset that should be received
     * @param   _swapPath  Path for the uniV2 swap
     */
    function swapToBorrowedAsset(
        address _collateralAsset,
        uint256 _minDebtAmountOut,
        address[] memory _swapPath
    ) public {
        IERC20 collateralToken = IERC20(_collateralAsset);

        // swap full amount of current balance of the token (everything that has been liquidated)
        uint256 amountToTrade = collateralToken.balanceOf(address(this));

        // approve uniswap access to the token
        collateralToken.approve(address(uniswapV2Router), amountToTrade);

        // Execute swap from _collateralAsset into requested ERC20 debt token
        uniswapV2Router.swapExactTokensForTokens(
            amountToTrade,
            _minDebtAmountOut,
            _swapPath,
            address(this),
            block.timestamp + 300 // 5 minutes deadline
        );
    }
}
