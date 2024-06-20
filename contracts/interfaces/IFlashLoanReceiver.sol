// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IAddressesProvider} from "./IAddressesProvider.sol";
import {ILendingPool} from "./ILendingPool.sol";

/**
 * @title IFlashLoanReceiver interface
 * @notice Interface for the IFlashLoanReceiver.
 * @author MELD team
 */
interface IFlashLoanReceiver {
    /**
     * @notice Executes the operation on the flash loan
     * @param _assets The assets being flash-borrowed
     * @param _amounts The amounts being flash-borrowed
     * @param _premiums The premiums of the flash loan
     * @param _initiator The initiator of the flash loan
     * @param _params Extra parameters for the flash loan
     * @return bool true if the operation was successful
     */
    function executeOperation(
        address[] calldata _assets,
        uint256[] calldata _amounts,
        uint256[] calldata _premiums,
        address _initiator,
        bytes calldata _params
    ) external returns (bool);

    /**
     * @notice Returns the IAddressesProvider
     * @return The IAddressesProvider
     */
    function ADDRESSES_PROVIDER() external view returns (IAddressesProvider); // solhint-disable-line func-name-mixedcase

    /**
     * @notice Returns the ILendingPool
     * @return The ILendingPool
     */
    function LENDING_POOL() external view returns (ILendingPool); // solhint-disable-line func-name-mixedcase
}
