// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title DataTypes library
 * @notice Defines the data structures of the protocol data
 * @author MELD team
 */
library DataTypes {
    struct ReserveData {
        //stores the reserve configuration
        ReserveConfigurationMap configuration;
        //the liquidity index. Expressed in ray
        uint128 liquidityIndex;
        //variable borrow index. Expressed in ray
        uint128 variableBorrowIndex;
        //the current supply rate. Expressed in ray
        uint128 currentLiquidityRate;
        //the current variable borrow rate. Expressed in ray
        uint128 currentVariableBorrowRate;
        //the current stable borrow rate. Expressed in ray
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        //the id of the reserve. Represents the position in the list of the active reserves
        uint8 id;
        //tokens addresses
        address mTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        //address of the interest rate strategy
        address interestRateStrategyAddress;
        //address of the YieldBoostStaking
        address yieldBoostStaking;
    }

    struct ReserveConfigurationMap {
        //bit 0-15: LTV
        //bit 16-31: Liq. threshold
        //bit 32-47: Liq. bonus
        //bit 48-55: Decimals
        //bit 56: Reserve is active
        //bit 57: reserve is frozen
        //bit 58: borrowing is enabled
        //bit 59: stable rate borrowing enabled
        //bit 60-63: reserved
        //bit 64-79: reserve factor
        //bit 80-111: supply cap USD, 0 = disabled
        //bit 112-143: borrow cap USD, 0 = disabled
        uint256 data;
    }

    struct ReserveConfigurationData {
        uint256 decimals;
        uint256 ltv;
        uint256 liquidationThreshold;
        uint256 liquidationBonus;
        uint256 reserveFactor;
        uint256 supplyCapUSD;
        uint256 borrowCapUSD;
        uint256 flashLoanLimitUSD;
        bool usageAsCollateralEnabled;
        bool isActive;
        bool isFrozen;
        bool borrowingEnabled;
        bool stableBorrowRateEnabled;
    }

    struct UserConfigurationMap {
        uint256 data;
        bool acceptGeniusLoan;
    }

    enum InterestRateMode {
        NONE,
        STABLE,
        VARIABLE
    }

    enum Action {
        NONE,
        DEPOSIT,
        BORROW
    }

    enum MeldBankerType {
        NONE,
        BANKER,
        GOLDEN
    }
}
