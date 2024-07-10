// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DataTypes} from "./DataTypes.sol";

/**
 * @title IMeldProtocolDataProvider interface
 * @notice Provides the data of the MELD protocol
 * @author MELD team
 */
interface IMeldProtocolDataProvider {
    struct TokenData {
        string symbol;
        address tokenAddress;
    }

    struct ReserveConfigurationData {
        uint256 decimals;
        uint256 ltv;
        uint256 liquidationThreshold;
        uint256 liquidationBonus;
        uint256 reserveFactor;
        uint256 supplyCapUSD;
        uint256 borrowCapUSD;
        bool usageAsCollateralEnabled;
        bool isActive;
        bool isFrozen;
        bool borrowingEnabled;
        bool stableBorrowRateEnabled;
    }

    /**
     * @notice Returns the tokens of all the reserves of the protocol
     * @return An array of TokenData objects containing the tokens symbol and address
     */
    function getAllReservesTokens() external view returns (TokenData[] memory);

    /**
     * @notice Returns the mTokens of all the reserves of the protocol
     * @return An array of TokenData objects with the mTokens symbol and address
     */
    function getAllMTokens() external view returns (TokenData[] memory);

    /**
     * @notice Checks if the reserve already exists
     * @param _asset The address of the underlying asset of the reserve
     * @return bool true if the reserve already exists, false otherwise
     */
    function reserveExists(address _asset) external view returns (bool);

    /**
     * @notice Returns the configuration data of a specific reserve
     * @param _asset The address of the reserve
     * @return reserveConfig Struct containing the reserve configuration data
     */
    function getReserveConfigurationData(
        address _asset
    ) external view returns (DataTypes.ReserveConfigurationData memory);

    /**
     * @notice Returns the user data of a specific user for a specific reserve
     * @param _asset The address of the reserve
     * @param _user The address of the user
     * @return currentMTokenBalance The current balance of the user in the reserve
     * @return currentStableDebt The current stable debt of the user in the reserve
     * @return currentVariableDebt The current variable debt of the user in the reserve
     * @return principalStableDebt The principal of the stable debt of the user in the reserve
     * @return scaledVariableDebt The scaled variable debt of the user in the reserve
     * @return stableBorrowRate The stable borrow rate of the user in the reserve
     * @return liquidityRate The liquidity rate of the reserve
     * @return stableRateLastUpdated The timestamp of the last stable rate update
     * @return usageAsCollateralEnabled Whether the user is using the reserve as collateral
     */
    function getUserReserveData(
        address _asset,
        address _user
    )
        external
        view
        returns (
            uint256 currentMTokenBalance,
            uint256 currentStableDebt,
            uint256 currentVariableDebt,
            uint256 principalStableDebt,
            uint256 scaledVariableDebt,
            uint256 stableBorrowRate,
            uint256 liquidityRate,
            uint40 stableRateLastUpdated,
            bool usageAsCollateralEnabled
        );

    /**
     * @notice Returns the addresses of the mToken, stable debt token and variable debt token of a specific asset
     * @param _asset The address of the asset
     * @return mTokenAddress The address of the mToken
     * @return stableDebtTokenAddress The address of the stable debt token
     * @return variableDebtTokenAddress The address of the variable debt token
     */
    function getReserveTokensAddresses(
        address _asset
    )
        external
        view
        returns (
            address mTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress
        );

    /**
     * @notice Returns the total supply and the supply cap of a specific asset
     * @param _asset The address of the asset
     * @return supplyCap The supply cap of the asset
     * @return currentSupplied The current total supply of the asset
     * @return supplyCapUSD The supply cap of the asset in USD
     * @return currentSuppliedUSD The current total supply of the asset in USD
     */
    function getSupplyCapData(
        address _asset
    )
        external
        view
        returns (
            uint256 supplyCap,
            uint256 currentSupplied,
            uint256 supplyCapUSD,
            uint256 currentSuppliedUSD
        );

    /**
     * @notice Returns the total borrow and the borrow cap of a specific asset
     * @param _asset The address of the asset
     * @return borrowCap The borrow cap of the asset
     * @return currentBorrowed The current total borrowed value of the asset
     * @return borrowCapUSD The borrow cap of the asset in USD
     * @return currentBorrowedUSD The current total borrowed value of the asset in USD
     */
    function getBorrowCapData(
        address _asset
    )
        external
        view
        returns (
            uint256 borrowCap,
            uint256 currentBorrowed,
            uint256 borrowCapUSD,
            uint256 currentBorrowedUSD
        );

    /**
     * @notice Returns the flash loan limit of a specific asset
     * @param _asset The address of the asset
     * @return flashLoanLimit The flash loan limit of the asset in the asset's decimals
     * @return flashLoanLimitUSD The flash loan limit of the asset in USD
     */
    function getFlashLoanLimitData(
        address _asset
    ) external view returns (uint256 flashLoanLimit, uint256 flashLoanLimitUSD);

    /**
     * @notice Returns the address of the YieldBoostStaking of a specific asset
     * @param _asset The address of the asset
     * @return The address of the YieldBoostStaking (or ZeroAddress if yield boost not enabled for the asset)
     */
    function getReserveYieldBoostStaking(address _asset) external view returns (address);

    /**
     * @notice Returns the reserve data of a specific asset
     * @param _asset The address of the reserve
     * @return availableLiquidity The liquidity available in the reserve
     * @return totalStableDebt The total stable debt of the reserve
     * @return totalVariableDebt The total variable debt of the reserve
     * @return liquidityRate The current liquidity rate
     * @return variableBorrowRate The current variable borrow rate
     * @return stableBorrowRate The current stable borrow rate
     * @return averageStableBorrowRate The average stable borrow rate
     * @return liquidityIndex The liquidity index
     * @return variableBorrowIndex The variable borrow index
     * @return lastUpdateTimestamp The timestamp of the last update
     */
    function getReserveData(
        address _asset
    )
        external
        view
        returns (
            uint256 availableLiquidity,
            uint256 totalStableDebt,
            uint256 totalVariableDebt,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            uint40 lastUpdateTimestamp
        );

    /**
     * @notice Checks if a user is accepting the Genius Loan
     * @param _user The address of the user
     */
    function isUserAcceptingGeniusLoan(address _user) external view returns (bool);

    /**
     * @notice Returns the configuration parameters of the MELD protocol
     * @return maxValidLtv The max amount of LTV of the protocol
     * @return maxValidLiquidationThreshold The max amount of liquidation threshold of the protocol
     * @return maxValidLiquidationBonus The max amount of liquidation bonus of the protocol
     * @return maxValidDecimals The max amount of decimals of the protocol
     * @return maxValidReserveFactor The max amount of reserve factor of the protocol
     * @return maxValidSupplyCapUSD The max amount of supply cap of the protocol in USD
     * @return maxValidBorrowCapUSD The max amount of borrow cap of the protocol in USD
     * @return maxflashLoanLimitUSD The max amount of flash loan limit in USD
     */
    function getReserveConfigurationMaxValues()
        external
        pure
        returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);
}
