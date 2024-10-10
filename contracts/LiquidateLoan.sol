// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {FlashLoanReceiverBase} from "./FlashLoanReceiverBase.sol";
import {IAddressesProvider} from "./interfaces/IAddressesProvider.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title LiquidateLoan
 * @author MELD team
 * @notice A contract that liquidates unhealthy loans leveraging flashloans and swaps the collateral back to the borrowed asset in a uniV2 protocol
 */
contract LiquidateLoan is FlashLoanReceiverBase, AccessControl {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IAddressesProvider public provider;
    IPriceOracle public priceOracle;
    IUniswapV2Router02 public uniswapV2Router;

    uint256 public myMinProfit; // In basis points (105_00 = 5% profit)

    address public lendingPoolAddr;

    // Will receive the profits from liquidations
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
     * @param   collateralAssetProfit  Profit from the liquidation in collateral asset
     * @param   usdProfit  Profit from the liquidation in USD (18 decimals)
     */
    event FlashLoanLiquidation(
        address indexed collateralAddress,
        address indexed debtAddress,
        address indexed liquidatedUser,
        uint256 flashLoanAmount,
        uint256 flashLoanPremium,
        uint256 actualDebtCovered,
        uint256 actualCollateralLiquidated,
        uint256 collateralAssetProfit,
        uint256 usdProfit
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

        myMinProfit = 105_00; // 5% profit

        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        treasury = _defaultAdmin;

        priceOracle = IPriceOracle(provider.getPriceOracle());
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
     * @notice  This function is used to set the minimum profit that the liquidator will get from the liquidation
     * @param   _myMinProfit  Minimum profit that the liquidator will get from the liquidation in basis points (105_00 = 5% profit)
     */
    function setMyMinProfit(uint256 _myMinProfit) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_myMinProfit > 100_00, "Invalid min profit");
        myMinProfit = _myMinProfit;
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
        (address collateralAssetAddress, address userToLiquidate, address[] memory swapPath) = abi
            .decode(_params, (address, address, address[]));

        // Approve tokens and liquidate unhealthy loan
        address debtAssetAddress = _assets[0];
        uint256 flashLoanAmount = _amounts[0];
        uint256 flashLoanPremium = _premiums[0];

        IERC20 debtAsset = IERC20(debtAssetAddress);
        IERC20 collateralAsset = IERC20(collateralAssetAddress);

        (uint256 collateralAssetPrice, ) = priceOracle.getAssetPrice(collateralAssetAddress);
        uint256 myMinProfitCollateral = _getMinProfitCollateral(
            debtAsset,
            collateralAsset,
            flashLoanAmount,
            collateralAssetPrice
        );

        debtAsset.approve(address(lendingPoolAddr), flashLoanAmount);

        (uint256 actualDebtCovered, uint256 actualCollateralLiquidated) = ILendingPool(
            lendingPoolAddr
        ).liquidationCall(
                collateralAssetAddress,
                debtAssetAddress,
                userToLiquidate,
                flashLoanAmount,
                false
            );

        _swapToDebtAsset(
            debtAsset,
            collateralAsset,
            flashLoanAmount,
            flashLoanPremium,
            swapPath,
            myMinProfitCollateral
        );

        uint256 collateralProfit = collateralAsset.balanceOf(address(this));
        uint256 usdProfit = (collateralProfit * collateralAssetPrice) /
            10 ** collateralAsset.decimals();

        collateralAsset.safeTransfer(treasury, collateralProfit);

        // Approve the LendingPool contract allowance to *pull* the owed amount
        debtAsset.approve(lendingPoolAddr, flashLoanAmount + flashLoanPremium);

        emit FlashLoanLiquidation(
            collateralAssetAddress,
            debtAssetAddress,
            userToLiquidate,
            flashLoanAmount,
            flashLoanPremium,
            actualDebtCovered,
            actualCollateralLiquidated,
            collateralProfit,
            usdProfit
        );

        return true;
    }

    /**
     * @notice This function is used to swap the collateral back to the borrowed asset
     * @param debtAsset ERC20 token of the debt asset
     * @param collateralAsset ERC20 token of the collateral asset
     * @param flashLoanAmount Amount of the flash loan
     * @param flashLoanPremium Premium of the flash loan
     * @param swapPath Path for the swap
     * @param myMinProfitCollateral Minimum profit in collateral asset
     */
    function _swapToDebtAsset(
        IERC20 debtAsset,
        IERC20 collateralAsset,
        uint256 flashLoanAmount,
        uint256 flashLoanPremium,
        address[] memory swapPath,
        uint256 myMinProfitCollateral
    ) internal {
        uint256 debtAssetAmountOut = flashLoanAmount +
            flashLoanPremium -
            debtAsset.balanceOf(address(this));
        uint256 maxAmountIn = collateralAsset.balanceOf(address(this)) - myMinProfitCollateral;

        collateralAsset.approve(address(uniswapV2Router), maxAmountIn);

        uniswapV2Router.swapTokensForExactTokens(
            debtAssetAmountOut,
            maxAmountIn,
            swapPath,
            address(this),
            block.timestamp + 300 // 5 minutes deadline
        );
    }

    /**
     * @notice This function is used to calculate the minimum profit in collateral asset
     * @param debtAsset ERC20 token of the debt asset
     * @param collateralAsset ERC20 token of the collateral asset
     * @param flashLoanAmount Amount of the flash loan
     * @param collateralAssetPrice Price of the collateral asset
     */
    function _getMinProfitCollateral(
        IERC20 debtAsset,
        IERC20 collateralAsset,
        uint256 flashLoanAmount,
        uint256 collateralAssetPrice
    ) internal view returns (uint256) {
        (uint256 debtAssetPrice, ) = priceOracle.getAssetPrice(address(debtAsset));
        uint256 flashLoanAmountUSD = (debtAssetPrice * flashLoanAmount) / debtAsset.decimals(); // in USD (18 decimals)

        uint256 myMinProfitUSD = (myMinProfit * flashLoanAmountUSD) / 10000;
        uint256 myMinProfitCollateral = (myMinProfitUSD * 10 ** collateralAsset.decimals()) /
            collateralAssetPrice; // in collateral asset decimals

        return myMinProfitCollateral;
    }
}
