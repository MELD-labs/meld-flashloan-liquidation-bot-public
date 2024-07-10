// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title Errors library
 * @notice Defines the error messages emitted by the different contracts of the Meld protocol
 * @dev Error messages prefix glossary:
 *  - VL = ValidationLogic
 *  - MATH = Math libraries
 *  - CT = Common errors between tokens (MToken, VariableDebtToken and StableDebtToken)
 *  - MT = MToken
 *  - SDT = StableDebtToken
 *  - VDT = VariableDebtToken
 *  - LP = LendingPool
 *  - AP = AddressesProvider
 *  - LPC = LendingPoolConfiguration
 *  - RL = ReserveLogic
 *  - LL = LiquidationLogic
 *  - P = Pausable
 *  - MB = MeldBankerNFT
 * @author MELD team
 */
library Errors {
    //common errors
    string public constant BORROW_ALLOWANCE_NOT_ENOUGH = "BORROW_ALLOWANCE_NOT_ENOUGH"; // User borrows on behalf, but allowance are too small
    string public constant INVALID_ADDRESS = "INVALID_ADDRESS"; // 'Invalid address provided'
    string public constant PRICE_ORACLE_NOT_SET = "PRICE_ORACLE_NOT_SET"; // 'Price oracle is not set'
    string public constant LENDING_RATE_ORACLE_NOT_SET = "LENDING_RATE_ORACLE_NOT_SET"; // 'Lending Rate oracle is not set'
    string public constant INVALID_ASSET_PRICE = "INVALID_ASSET_PRICE"; // 'Price from oracle invalid'
    string public constant INVALID_MARKET_BORROW_RATE = "INVALID_MARKET_BORROW_RATE"; // Market borrow rate from the oracle is invalid
    string public constant CURRENT_AVAILABLE_LIQUIDITY_NOT_ENOUGH =
        "CURRENT_AVAILABLE_LIQUIDITY_NOT_ENOUGH"; // 'The current liquidity is not enough'
    string public constant INCONSISTENT_ARRAY_SIZE = "INCONSISTENT_ARRAY_SIZE"; // 'Array sizes do not match'
    string public constant EMPTY_ARRAY = "EMPTY_ARRAY"; // 'Empty array'
    string public constant EMPTY_VALUE = "EMPTY_VALUE"; // 'Empty value'
    string public constant VALUE_ABOVE_100_PERCENT = "VALUE_ABOVE_100_PERCENT"; // 'Value is above 100%'
    string public constant UPGRADEABILITY_NOT_ALLOWED = "UPGRADEABILITY_NOT_ALLOWED";

    //contract specific errors
    string public constant VL_INVALID_AMOUNT = "VL_INVALID_AMOUNT"; // 'Amount must be greater than 0'
    string public constant VL_NO_ACTIVE_RESERVE = "VL_NO_ACTIVE_RESERVE"; // 'Action requires an active reserve'
    string public constant VL_RESERVE_FROZEN = "VL_RESERVE_FROZEN"; // 'Action cannot be performed because the reserve is frozen'
    string public constant VL_CURRENT_AVAILABLE_LIQUIDITY_NOT_ENOUGH_FOR_BORROW =
        "VL_CURRENT_AVAILABLE_LIQUIDITY_NOT_ENOUGH_FOR_BORROW"; // 'The current liquidity is not enough to borrow the amount requested'
    string public constant VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE =
        "VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE"; // 'User cannot withdraw more than the available balance'
    string public constant VL_TRANSFER_NOT_ALLOWED = "VL_TRANSFER_NOT_ALLOWED"; // 'Transfer cannot be allowed.'
    string public constant VL_BORROWING_NOT_ENABLED = "VL_BORROWING_NOT_ENABLED"; // 'Borrowing is not enabled'
    string public constant VL_INVALID_INTEREST_RATE_MODE_SELECTED =
        "VL_INVALID_INTEREST_RATE_MODE_SELECTED"; // 'Invalid interest rate mode selected'
    string public constant VL_COLLATERAL_BALANCE_IS_0 = "VL_COLLATERAL_BALANCE_IS_0"; // 'The collateral balance is 0'
    string public constant VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD =
        "VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD"; // 'Health factor is less than the liquidation threshold'
    string public constant VL_COLLATERAL_CANNOT_COVER_NEW_BORROW =
        "VL_COLLATERAL_CANNOT_COVER_NEW_BORROW"; // 'There is not enough collateral to cover a new borrow'
    string public constant VL_STABLE_BORROWING_NOT_ENABLED = "VL_STABLE_BORROWING_NOT_ENABLED"; // stable borrowing not enabled
    string public constant VL_COLLATERAL_SAME_AS_BORROWING_CURRENCY =
        "VL_COLLATERAL_SAME_AS_BORROWING_CURRENCY"; // collateral is (mostly) the same currency that is being borrowed
    string public constant VL_AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE =
        "VL_AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE"; // 'The requested amount is greater than the max loan size in stable rate mode
    string public constant VL_NO_DEBT_OF_SELECTED_TYPE = "VL_NO_DEBT_OF_SELECTED_TYPE"; // 'for repayment of stable debt, the user needs to have stable debt, otherwise, he needs to have variable debt'
    string public constant VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF =
        "VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF"; // 'To repay on behalf of a user an explicit amount to repay is needed'
    string public constant VL_UNDERLYING_BALANCE_NOT_GREATER_THAN_0 =
        "VL_UNDERLYING_BALANCE_NOT_GREATER_THAN_0"; // 'The underlying balance needs to be greater than 0'
    string public constant VL_DEPOSIT_ALREADY_IN_USE = "VL_DEPOSIT_ALREADY_IN_USE"; // 'User deposit is already being used as collateral'
    string public constant VL_RESERVE_SUPPLY_CAP_REACHED = "VL_RESERVE_SUPPLY_CAP_REACHED"; // 'Reserve reached its supply cap'
    string public constant VL_RESERVE_BORROW_CAP_REACHED = "VL_RESERVE_BORROW_CAP_REACHED"; // 'Reserve reached its borrow cap'
    string public constant VL_FLASH_LOAN_AMOUNT_OVER_LIMIT = "VL_FLASH_LOAN_AMOUNT_OVER_LIMIT"; // 'Flash loan amount of one of the assets is over the limit'
    string public constant CT_RESERVE_TOKEN_ALREADY_INITIALIZED =
        "CT_RESERVE_TOKEN_ALREADY_INITIALIZED"; // 'MToken, StableDebtToken, or VariableDebtToken has already been initialized'
    string public constant RL_RESERVE_ALREADY_INITIALIZED = "RL_RESERVE_ALREADY_INITIALIZED"; // 'Reserve has already been initialized'
    string public constant LPC_RESERVE_LIQUIDITY_NOT_0 = "LPC_RESERVE_LIQUIDITY_NOT_0"; // 'The liquidity of the reserve needs to be 0'
    string public constant LPC_INVALID_CONFIGURATION = "LPC_INVALID_CONFIGURATION"; // 'Invalid risk parameters for the reserve'
    string public constant LPC_RESERVE_DOES_NOT_EXIST = "LPC_RESERVE_DOES_NOT_EXIST"; // 'Reserve does not exist/has not been initialized'
    string public constant LL_HEALTH_FACTOR_NOT_BELOW_THRESHOLD =
        "LL_HEALTH_FACTOR_NOT_BELOW_THRESHOLD"; // 'Health factor is not below the threshold'
    string public constant LL_COLLATERAL_CANNOT_BE_LIQUIDATED =
        "LL_COLLATERAL_CANNOT_BE_LIQUIDATED"; // 'The collateral chosen cannot be liquidated'
    string public constant LL_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER =
        "LL_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER"; // 'User did not borrow the specified currency'
    string public constant LL_NOT_ENOUGH_LIQUIDITY_TO_LIQUIDATE =
        "LL_NOT_ENOUGH_LIQUIDITY_TO_LIQUIDATE"; // "There isn't enough liquidity available to liquidate"

    string public constant FLL_INVALID_FLASH_LOAN_EXECUTOR_RETURN =
        "FLL_INVALID_FLASH_LOAN_EXECUTOR_RETURN";
    string public constant MATH_MULTIPLICATION_OVERFLOW = "MATH_MULTIPLICATION_OVERFLOW";
    string public constant MATH_ADDITION_OVERFLOW = "MATH_ADDITION_OVERFLOW";
    string public constant MATH_DIVISION_BY_ZERO = "MATH_DIVISION_BY_ZERO";
    string public constant RL_LIQUIDITY_INDEX_OVERFLOW = "RL_LIQUIDITY_INDEX_OVERFLOW"; //  Liquidity index overflows uint128
    string public constant RL_VARIABLE_BORROW_INDEX_OVERFLOW = "RL_VARIABLE_BORROW_INDEX_OVERFLOW"; //  Variable borrow index overflows uint128
    string public constant RL_LIQUIDITY_RATE_OVERFLOW = "RL_LIQUIDITY_RATE_OVERFLOW"; //  Liquidity rate overflows uint128
    string public constant RL_VARIABLE_BORROW_RATE_OVERFLOW = "RL_VARIABLE_BORROW_RATE_OVERFLOW"; //  Variable borrow rate overflows uint128
    string public constant RL_STABLE_BORROW_RATE_OVERFLOW = "RL_STABLE_BORROW_RATE_OVERFLOW"; //  Stable borrow rate overflows uint128
    string public constant CT_INVALID_MINT_AMOUNT = "CT_INVALID_MINT_AMOUNT"; //invalid amount to mint
    string public constant CT_INVALID_BURN_AMOUNT = "CT_INVALID_BURN_AMOUNT"; //invalid amount to burn
    string public constant MT_INVALID_OWNER = "MT_INVALID_OWNER"; // The owner passed to the permit function cannot be the zero address
    string public constant MT_INVALID_DEADLINE = "MT_INVALID_DEADLINE"; // The permit deadline has expired
    string public constant MT_INVALID_SIGNATURE = "MT_INVALID_SIGNATURE"; // The permit signature is invalid
    string public constant LP_CALLER_MUST_BE_AN_MTOKEN = "LP_CALLER_MUST_BE_AN_MTOKEN";
    string public constant LP_NO_MORE_RESERVES_ALLOWED = "LP_NO_MORE_RESERVES_ALLOWED";
    string public constant LP_USER_NOT_ACCEPT_GENIUS_LOAN = "LP_USER_NOT_ACCEPT_GENIUS_LOAN";
    string public constant LP_MELD_BANKER_NFT_LOCKED = "LP_MELD_BANKER_NFT_LOCKED";
    string public constant LP_NOT_OWNER_OF_MELD_BANKER_NFT = "LP_NOT_OWNER_OF_MELD_BANKER_NFT";
    string public constant LP_INVALID_MELD_BANKER_TYPE = "LP_INVALID_MELD_BANKER_TYPE";
    string public constant LP_INVALID_ACTION = "LP_INVALID_ACTION";
    string public constant LP_INVALID_YIELD_BOOST_MULTIPLIER = "LP_INVALID_YIELD_BOOST_MULTIPLIER"; // yield boost multiplier value is invalied
    string public constant LP_YIELD_BOOST_STAKING_NOT_ENABLED =
        "LP_YIELD_BOOST_STAKING_NOT_ENABLED"; // yield boost was either never enabled or has been disabled
    string public constant LP_MELD_BANKER_NFT_ALREADY_SET = "LP_MELD_BANKER_NFT_ALREADY_SET";
    string public constant RC_INVALID_LTV = "RC_INVALID_LTV";
    string public constant RC_INVALID_LIQ_THRESHOLD = "RC_INVALID_LIQ_THRESHOLD";
    string public constant RC_INVALID_LIQ_BONUS = "RC_INVALID_LIQ_BONUS";
    string public constant RC_INVALID_DECIMALS = "RC_INVALID_DECIMALS";
    string public constant RC_INVALID_RESERVE_FACTOR = "RC_INVALID_RESERVE_FACTOR";
    string public constant RC_INVALID_SUPPLY_CAP_USD = "RC_INVALID_SUPPLY_CAP_USD";
    string public constant RC_INVALID_BORROW_CAP_USD = "RC_INVALID_BORROW_CAP_USD";
    string public constant RC_INVALID_FLASHLOAN_LIMIT_USD = "RC_INVALID_FLASHLOAN_LIMIT_USD";
    string public constant AP_INVALID_ADDRESS_ID = "AP_INVALID_ADDRESS_ID";
    string public constant AP_CANNOT_UPDATE_ADDRESS = "AP_CANNOT_UPDATE_ADDRESS";
    string public constant AP_CANNOT_UPDATE_ROLE = "AP_CANNOT_UPDATE_ROLE";
    string public constant AP_CANNOT_REMOVE_LAST_ADMIN = "AP_CANNOT_REMOVE_LAST_ADMIN";
    string public constant AP_ROLE_NOT_DESTROYABLE = "AP_ROLE_NOT_DESTROYABLE";
    string public constant AP_ROLE_ALREADY_DESTROYED = "AP_ROLE_ALREADY_DESTROYED";
    string public constant AP_ROLE_HAS_MEMBERS = "AP_ROLE_HAS_MEMBERS";
    string public constant AP_CANNOT_STOP_UPGRADEABILITY = "AP_CANNOT_STOP_UPGRADEABILITY";
    string public constant UL_INVALID_INDEX = "UL_INVALID_INDEX";
    string public constant LPC_NOT_CONTRACT = "LPC_NOT_CONTRACT";
    string public constant SDT_STABLE_DEBT_OVERFLOW = "SDT_STABLE_DEBT_OVERFLOW";
    string public constant SDT_BURN_EXCEEDS_BALANCE = "SDT_BURN_EXCEEDS_BALANCE";
    string public constant MB_NFT_BLOCKED = "MB_NFT_BLOCKED";
    string public constant MB_METADATA_ADDRESS_NOT_SET = "MB_METADATA_ADDRESS_NOT_SET";
    string public constant MB_INVALID_NFT_ID = "MB_INVALID_NFT_ID";
    string public constant MB_INVALID_LENDING_POOL = "MB_INVALID_LENDING_POOL";
    string public constant YB_REWARDS_INVALID_EPOCH = "YB_REWARDS_INVALID_EPOCH";
    string public constant YB_REWARDS_CURRENT_OR_FUTURE_EPOCH =
        "YB_REWARDS_CURRENT_OR_FUTURE_EPOCH";
    string public constant YB_REWARDS_INVALID_AMOUNT = "YB_REWARDS_INVALID_AMOUNT";
    string public constant YB_INSUFFICIENT_ALLOWANCE = "YB_INSUFFICIENT_ALLOWANCE";
    string public constant YB_STAKER_DOES_NOT_EXIST = "YB_STAKER_DOES_NOT_EXIST";
    string public constant YB_INVALID_EPOCH = "YB_INVALID_EPOCH";
    string public constant YB_INVALID_INIT_TIMESTAMP = "YB_INVALID_INIT_TIMESTAMP";
    string public constant YB_INVALID_ASSET = "YB_INVALID_ASSET";
    string public constant YB_ONLY_FACTORY = "YB_ONLY_FACTORY";
    string public constant YB_ONLY_YB_STAKING = "YB_ONLY_YB_STAKING";
    string public constant YB_ALREADY_INITIALIZED = "YB_ALREADY_INITIALIZED";
    string public constant YB_SENDER_CANNOT_SET_STAKE_AMOUNT = "YB_SENDER_CANNOT_SET_STAKE_AMOUNT";
    string public constant YB_INVALID_EPOCH_SIZE = "YB_INVALID_EPOCH_SIZE";
    string public constant YB_USER_NOT_ACCEPT_GENIUS_LOAN = "YB_USER_NOT_ACCEPT_GENIUS_LOAN";
    string public constant YB_INVALID_MELD_STAKING_STORAGE = "YB_INVALID_MELD_STAKING_STORAGE";
    string public constant YB_INVALID_MELD_TOKEN = "YB_INVALID_MELD_TOKEN";
    string public constant YB_INCONSISTENT_STATE = "YB_INCONSISTENT_STATE";
}
