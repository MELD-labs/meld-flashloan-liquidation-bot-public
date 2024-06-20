// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {
    IFlashLoanReceiver,
    IAddressesProvider,
    ILendingPool
} from "./interfaces/IFlashLoanReceiver.sol";

/**
 * @title FlashLoanReceiverBase contract
 * @notice Implements the base contract to receive flash loans
 * @author MELD team
 */
abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IAddressesProvider public immutable override ADDRESSES_PROVIDER; // solhint-disable-line immutable-vars-naming
    ILendingPool public immutable override LENDING_POOL; // solhint-disable-line immutable-vars-naming

    /**
     * @notice Constructor
     * @param _addressesProvider The protocol address provider
     */
    constructor(IAddressesProvider _addressesProvider) {
        ADDRESSES_PROVIDER = _addressesProvider;
        LENDING_POOL = ILendingPool(_addressesProvider.getLendingPool());
    }
}
