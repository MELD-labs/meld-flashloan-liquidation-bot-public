// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title IPriceOracle interface
 * @notice Interface for any price oracle used in MELD
 * @author MELD team
 */
interface IPriceOracle {
    /**
     * @notice Retrieves the price of an asset from the list of oracles
     * @dev Iterates through the list of oracles until a successful price retrieval
     * @param _asset The address of the asset
     * @return price The price of the asset
     * @return success Boolean indicating if the price retrieval was successful
     */
    function getAssetPrice(address _asset) external view returns (uint256 price, bool success);
}
