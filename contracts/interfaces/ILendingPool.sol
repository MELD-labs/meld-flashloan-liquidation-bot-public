// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DataTypes} from "./DataTypes.sol";

/**
 * @title ILendingPool interface
 * @notice Interface for the LendingPool contract
 * @author MELD team
 */
interface ILendingPool {
    /**
     * @notice Emitted when the LendingPool is initialized
     * @param executedBy The address of the user executing the initialization
     * @param addressesProvider The address of the LendingPoolAddressesProvider
     */
    event LendingPoolInitialized(address indexed executedBy, address indexed addressesProvider);

    /**
     * @notice Emitted when the yield boost amount is refreshed.
     * @param reserve The address of the reserve
     * @param user The address of the user
     * @param newStakeAmount The new stake amount
     */
    event RefreshYieldBoostAmount(
        address indexed reserve,
        address indexed user,
        uint256 newStakeAmount
    );

    /**
     * @notice Emitted when the yield boost percentage is set.
     * @param reserve The address of the reserve
     * @param meldBankerType The MeldBankerType
     * @param action The action
     * @param oldYieldBoostPercentage The old yield boost percentage
     * @param newYieldBoostPercentage The new yield boost percentage
     */
    event SetYieldBoostMultplier(
        address indexed reserve,
        DataTypes.MeldBankerType indexed meldBankerType,
        DataTypes.Action indexed action,
        uint256 oldYieldBoostPercentage,
        uint256 newYieldBoostPercentage
    );

    /**
     * @notice Emitted when the liquidtion protocol fee is updated
     * @param executedBy The address of the user executing the update
     * @param oldLiquidationProtocolFeePercentage The old value of the liquidation protocol fee
     * @param newLiquidationProtocolFeePercentage The new value of the liquidation protocol fee
     */
    event LiquidtionProtocolFeePercentageUpdated(
        address indexed executedBy,
        uint256 oldLiquidationProtocolFeePercentage,
        uint256 newLiquidationProtocolFeePercentage
    );

    /**
     * @notice Emitted when the flash loan premium is updated
     * @param executedBy The address of the user executing the update
     * @param oldFlashLoanPremiumTotal The old value of the flash loan premium
     * @param newFlashLoanPremiumTotal The new value of the flash loan premium
     */
    event FlashLoanPremiumUpdated(
        address indexed executedBy,
        uint256 oldFlashLoanPremiumTotal,
        uint256 newFlashLoanPremiumTotal
    );

    /**
     * @notice Emitted when the MeldBankerNFT is set
     * @param executedBy The address of the user executing the update
     * @param meldBankerNFT The address of the MeldBankerNFT
     */
    event MeldBankerNFTSet(address indexed executedBy, address meldBankerNFT);

    /**
     * @notice Function to deposit an asset into the reserve. A corresponding amount of the overlying asset (mToken) is minted
     * @dev If it's the first deposit, the user can decide if s/he wants to use the deposit as collateral or not
     * @param _asset Address of the underlying asset to deposit
     * @param _amount Amount to deposit
     *  - Send the value type(uint256).max in order to deposit the caller's whole asset balance
     * @param _onBehalfOf Address of the user who will receive the mTokens, same as msg.sender if the user is acting on her/his behalf
     * @param _useAsCollateralOnFirstDeposit true if the deposit will be used as collateral if it's the first deposit, false otherwise
     * @param _tokenId The  Meld Banker NFT tokenId to be used to receive protocol benefits
     * @return The final amount to be deposited
     */
    function deposit(
        address _asset,
        uint256 _amount,
        address _onBehalfOf,
        bool _useAsCollateralOnFirstDeposit,
        uint256 _tokenId
    ) external returns (uint256);

    /**
     * @notice Withdraws an `amount` of underlying asset from the reserve, burning the equivalent mTokens owned
     * E.g. User has 100 mUSDC, calls withdraw() and receives 100 USDC, burning the 100 mUSDC
     * @param _asset The address of the underlying asset to withdraw
     * @param _onBehalfOf User address on behalf of whom the caller is acting.
     *   - Must be the same as msg.sender if the user is acting on own behalf. Can only be different from msg.sender if the caller has the Genius Loan role
     * @param _amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the caller's whole mToken balance, within the constraints of the available liquidity
     * @param _to Address that will receive the underlying asset, same as msg.sender if the user
     *   wants to receive it on her/his own wallet, or a different address if the beneficiary is a
     *   different wallet
     * @return The final amount withdrawn
     */
    function withdraw(
        address _asset,
        address _onBehalfOf,
        uint256 _amount,
        address _to
    ) external returns (uint256);

    /**
     * @notice Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
     * already deposited enough collateral, or s/he was given enough allowance by a credit delegator on the
     * corresponding debt token (StableDebtToken or VariableDebtToken)
     * - E.g. User borrows 100 USDC passing as `onBehalfOf` her/his own address, receiving the 100 USDC in her/his wallet
     *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
     * @param _asset The address of the underlying asset to borrow
     * @param _amount The amount to be borrowed
     *   - Send the value type(uint256).max in order to borrow the onBehalfOf addresses's maximum available amount,
     *   within the contratints of the collateral LTV and the amount already borrowed. When interest rate mode is Stable, the max amount
     *   will further be constrained by the max total stable loan percent. In most cases, this will be the applicable constraint for stable borrowing.
     *   When interest rate mode is Variable, the max amount will further be constrained by the reserve's available liquidity.
     * @param _interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
     * @param _onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
     * calling the function if s/he wants to borrow against her/his own collateral, or the address of the credit delegator
     * if s/he has been given credit delegation allowance
     * @param _tokenId The  Meld Banker NFT tokenId to be used to receive protocol benefits
     * @return The final amount borrowed
     */
    function borrow(
        address _asset,
        uint256 _amount,
        uint256 _interestRateMode,
        address _onBehalfOf,
        uint256 _tokenId
    ) external returns (uint256);

    /**
     * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens ownπed
     * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
     * @param _asset The address of the borrowed underlying asset previously borrowed
     * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`,
     *   within the constraints of the caller's debt asset balance
     * @param _rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable
     * @param _onBehalfOf Address of the user who will get her/his debt reduced/removed. Should be the address of the
     * user calling the function if he wants to reduce/remove her/his own debt, or the address of any other
     * other borrower whose debt should be removed
     * @return The final amount repaid
     */
    function repay(
        address _asset,
        uint256 _amount,
        uint256 _rateMode,
        address _onBehalfOf
    ) external returns (uint256);

    /**
     * @notice Function to liquidate a non-healthy position collateral-wise, with Health Factor below 1
     * - The caller (liquidator) covers `_debtToCover` amount of debt of the user getting liquidated, and receives
     *   a proportional amount of the `_collateralAsset` plus a bonus to cover market risk
     * @param _collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
     * @param _debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
     * @param _user The address of the borrower getting liquidated
     * @param _debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
     *   - Send the value type(uint256).max in order to liquidate the whole debt of the user, if there is enough collateral to cover it.
     *  Otherwise, passing this value will result in the max possible debt amount being paid back based on the max possible amount of collateral
     *  that can be liquidated
     * @param _receiveMToken `true` if the liquidator wants to receive the collateral mTokens, `false` if s/he wants
     * to receive the underlying collateral asset directly
     * @return actualDebtToLiquidate The total amount of debt covered by the liquidator
     * @return maxCollateralToLiquidate The total amount of collateral liquidated. This may not be the amount received by the liquidator if there is a protocol fee.
     */
    function liquidationCall(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtToCover,
        bool _receiveMToken
    ) external returns (uint256, uint256);

    /**
     * @notice Allows Smart Contracts to access the liquidity of the pool within one transaction, as long as the amount taken plus a fee is returned
     * @param _receiverAddress The address of the contract receiving the funds. The receiver should implement the IFlashLoanReceiver interface.
     * @param _assets the addresses of the assets being flash-borrowed
     * @param _amounts the amounts amounts being flash-borrowed
     * @param _params Variadic packed params to pass to the receiver as extra information
     */
    function flashLoan(
        address _receiverAddress,
        address[] calldata _assets,
        uint256[] calldata _amounts,
        bytes calldata _params
    ) external;

    /**
     * @notice Validates and finalizes an mToken transfer
     * @dev Only callable by the overlying mToken of the `asset`
     * @param _asset The address of the underlying asset of the mToken
     * @param _from The user from which the mTokens are transferred
     * @param _to The user receiving the mTokens
     * @param _amount The amount being transferred/withdrawn
     * @param _balanceFromBefore The mToken balance of the `from` user before the transfer
     * @param _balanceToBefore The mToken balance of the `to` user before the transfer
     */
    function finalizeTransfer(
        address _asset,
        address _from,
        address _to,
        uint256 _amount,
        uint256 _balanceFromBefore,
        uint256 _balanceToBefore
    ) external;

    /**
     * @notice Initializes a reserve
     * @dev Only callable by the LendingPoolConfigurator contract
     * @param _asset The address of the underlying asset of the reserve
     * @param _mTokenAddress The address of the overlying mToken contract
     * @param _stableDebtTokenAddress The address of the contract managing the stable debt of the reserve
     * @param _variableDebtTokenAddress The address of the contract managing the variable debt of the reserve
     * @param _interestRateStrategyAddress The address of the interest rate strategy contract
     */
    function initReserve(
        address _asset,
        address _mTokenAddress,
        address _stableDebtTokenAddress,
        address _variableDebtTokenAddress,
        address _interestRateStrategyAddress
    ) external;

    /**
     * @notice Updates the address of the interest rate strategy contract
     * @dev Only callable by the LendingPoolConfigurator contract
     * @param _asset The address of the underlying asset of the reserve
     * @param _rateStrategyAddress The address of the interest rate strategy contract
     */
    function setReserveInterestRateStrategyAddress(
        address _asset,
        address _rateStrategyAddress
    ) external;

    /**
     * @notice Updates the address of the yield boost staking contract
     * @dev Only callable by the LendingPoolConfigurator contract
     * @param _asset The address of the underlying asset of the reserve
     * @param _yieldBoostStaking The address of the yield boost staking contract
     */
    function setYieldBoostStakingAddress(address _asset, address _yieldBoostStaking) external;

    /**
     * @notice Allows depositors to enable/disable a specific deposited asset as collateral
     * @param _asset The address of the underlying asset deposited
     * @param _useAsCollateral `true` if the user wants to use the deposit as collateral, `false` otherwise
     */
    function setUserUseReserveAsCollateral(address _asset, bool _useAsCollateral) external;

    /**
     * @notice Allows depositors to enable/disable genius loans
     * @param _acceptGeniusLoan True if the user is accepting the genius loan, false otherwise
     */
    function setUserAcceptGeniusLoan(bool _acceptGeniusLoan) external;

    /**
     * @notice Sets the configuration bitmap of the reserve as a whole
     * @dev Only callable by the LendingPoolConfigurator contract
     * @param _asset The address of the underlying asset of the reserve
     * @param _configuration The new configuration bitmap
     */
    function setConfiguration(address _asset, uint256 _configuration) external;

    /**
     * @notice Sets the percentage of the liquidation reward that will be redirected to the protocol
     * @dev Only callable by the pool admin
     * @param _liquidtionProtocolFeePercentage The new percentage of the liquidation reward that will be redirected to the protocol
     */
    function setLiquidationProtocolFeePercentage(uint256 _liquidtionProtocolFeePercentage) external;

    /**
     * @notice Sets the multiplier that a user will receive for yield boost staking for the lending pool action and Meld Banker Type
     * @dev This multiplier is multiplied by the user's MToken balance (deposit multiplier) and/or debt token balance (borrow multiplier) to calculate the
     * yield boost stake amount. Only callable by the pool admin.
     * @param _asset The address of the underlying asset of the reserve
     * @param _meldBankerType The MeldBankerType
     * @param _action The action
     * @param _yieldBoostMultiplier The yield boost multiplier
     */
    function setYieldBoostMultiplier(
        address _asset,
        DataTypes.MeldBankerType _meldBankerType,
        DataTypes.Action _action,
        uint256 _yieldBoostMultiplier
    ) external;

    /**
     * @notice Refreshes the yield boost amount for the lending pool.
     * @param _user The address of the user
     * @param _asset The address of the underlying asset of the reserve
     * @return newStakeAmount The new stake amount
     */
    function refreshYieldBoostAmount(
        address _user,
        address _asset
    ) external returns (uint256 newStakeAmount);

    /**
     * @notice Sets the flash loan premium
     * @dev Only callable by the pool admin
     * @param _flashLoanPremiumTotal The new flash loan premium
     */
    function setFlashLoanPremium(uint256 _flashLoanPremiumTotal) external;

    /**
     * @notice Sets the address of the MeldBankerNFT, obtaining the address from the AddressesProvider
     * @dev Only callable by the pool admin
     */
    function setMeldBankerNFT() external;

    /**
     * @notice Returns the user account data across all the reserves
     * @param _user The address of the user
     * @return totalCollateralUSD The total collateral in USD of the user
     * @return totalDebtUSD The total debt in USD of the user
     * @return availableBorrowsUSD The borrowing power left of the user
     * @return currentLiquidationThreshold The liquidation threshold of the user
     * @return ltv The loan to value of the user
     * @return healthFactor The current health factor of the user
     */
    function getUserAccountData(
        address _user
    )
        external
        view
        returns (
            uint256 totalCollateralUSD,
            uint256 totalDebtUSD,
            uint256 availableBorrowsUSD,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );

    /**
     * @notice Returns the configuration of the user across all the reserves
     * @param _user The user address
     * @return The configuration of the user
     */
    function getUserConfiguration(
        address _user
    ) external view returns (DataTypes.UserConfigurationMap memory);

    /**
     * @notice Returns the ongoing normalized income for the reserve
     * @dev A value of 1e27 means there is no income. As time passes, the income is accrued
     * @dev A value of 2*1e27 means for each unit of asset one unit of income has been accrued
     * @param _asset The address of the underlying asset of the reserve
     * @return The normalized income expressed in ray
     */
    function getReserveNormalizedIncome(address _asset) external view returns (uint256);

    /**
     * @notice Returns the ongoing normalized variable debt for the reserve
     * @dev A value of 1e27 means there is no debt. As time passes, the income is accrued
     * @dev A value of 2*1e27 means that for each unit of debt, one unit worth of interest has been accumulated
     * @param _asset The address of the underlying asset of the reserve
     * @return The normalized variable debt expressed in ray
     */
    function getReserveNormalizedVariableDebt(address _asset) external view returns (uint256);

    /**
     * @notice Returns the reserve data of the specific `_asset`
     * @param _asset The address of the underlying asset of the reserve
     * @return The data object of the reserve
     */
    function getReserveData(address _asset) external view returns (DataTypes.ReserveData memory);

    /**
     * @notice Returns the list of the initialized reserves
     * @return The list of the initialized reserves
     */
    function getReservesList() external view returns (address[] memory);

    /**
     * @notice Returns the configuration of the reserve
     * @param _asset The address of the underlying asset of the reserve
     * @return The configuration of the reserve as a ReserveConfigurationMap
     */
    function getConfiguration(
        address _asset
    ) external view returns (DataTypes.ReserveConfigurationMap memory);

    /**
     * @notice Checks if the reserve already exists
     * @param _asset The address of the underlying asset of the reserve
     * @return bool true if the reserve already exists, false otherwise
     */
    function reserveExists(address _asset) external view returns (bool);

    /**
     * @notice Returns the percentage of available liquidity that can be borrowed at once at stable rate
     * @return The percentage of available liquidity that can be borrowed at once at stable rate
     */
    function maxStableRateBorrowSizePercent() external view returns (uint256);

    /**
     * @notice Returns the fee on flash loans
     * @return The fee on flash loans
     */
    function flashLoanPremiumTotal() external view returns (uint256);

    /**
     * @notice Returns the maximum number of reserves supported
     * @return The maximum number of reserves supported
     */
    function MAX_NUMBER_OF_RESERVES() external view returns (uint256); // solhint-disable-line func-name-mixedcase

    /**
     * @notice Gets the percentage of the liquidation reward that will be redirected to the protocol
     * @return The percentage of the liquidation reward that will be redirected to the protocol
     */
    function liquidationProtocolFeePercentage() external view returns (uint256);

    /**
     * @notice Checks if the user is already using a Meld Banker NFT. If so, the user may not be able to use any Meld Banker NFT for other actions.
     * @dev Generated getter
     * @param _user The address of the user
     * @return bool true if the Meld Banker NFT is blocked, false otherwise
     */
    function isUsingMeldBanker(address _user) external view returns (bool);

    /**
     * @notice Returns the Meld Banker data for the user
     * @dev Generated getter
     * @param _user The address of the user
     * @return The MeldBankerData tokenId
     * @return The MeldBankerData asset
     * @return The MeldBankerData meldBankerType
     * @return The MeldBankerData action
     */
    function userMeldBankerData(
        address _user
    ) external view returns (uint256, address, DataTypes.MeldBankerType, DataTypes.Action);

    /**
     * @notice Returns the yield boost multiplier for the lending pool action and Meld Banker Type
     * @dev Generated getter
     * @param _meldBankerType The type of Meld Banker
     * @param _action The action
     * @return The yield boost multiplier
     */
    function yieldBoostMultipliers(
        DataTypes.MeldBankerType _meldBankerType,
        DataTypes.Action _action
    ) external view returns (uint256);
}
