// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title IAddressesProvider interface
 * @notice Provides the interface to fetch the protocol's addresses and roles
 * @author MELD team
 */
interface IAddressesProvider {
    /**
     * @notice Emitted when the Lending Pool contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the Lending Pool contract.
     * @param newAddress The new address of the Lending Pool contract.
     */
    event LendingPoolUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the Lending Pool Configurator contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the Lending Pool Configurator contract.
     * @param newAddress The new address of the Lending Pool Configurator contract.
     */
    event LendingPoolConfiguratorUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the Protocol Data Provider contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the Protocol Data Provider contract.
     * @param newAddress The new address of the Protocol Data Provider contract.
     */
    event ProtocolDataProviderUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the Price Oracle contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the Price Oracle contract.
     * @param newAddress The new address of the Price Oracle contract.
     */
    event PriceOracleUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the Lending Rate Oracle contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the Lending Rate Oracle contract.
     * @param newAddress The new address of the Lending Rate Oracle contract.
     */
    event LendingRateOracleUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the MeldBankerNFT contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the MeldBankerNFT contract.
     * @param newAddress The new address of the MeldBankerNFT contract.
     */
    event MeldBankerNFTUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the MeldBankerNFTMinter contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the MeldBankerNFTMinter contract.
     * @param newAddress The new address of the MeldBankerNFTMinter contract.
     */
    event MeldBankerNFTMinterUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the YieldBoostFactory contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the YieldBoostFactory contract.
     * @param newAddress The new address of the YieldBoostFactory contract.
     */
    event YieldBoostFactoryUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the MeldToken contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the MeldToken contract.
     * @param newAddress The new address of the MeldToken contract.
     */
    event MeldTokenUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when the MeldStakingStorage contract is updated.
     * @param executedBy The address that executed the update.
     * @param oldAddress The old address of the MeldStakingStorage contract.
     * @param newAddress The new address of the MeldStakingStorage contract.
     */
    event MeldStakingStorageUpdated(
        address indexed executedBy,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when an address is set for a specific purpose.
     * @param executedBy The address that executed the action of setting the address.
     * @param id The identifier of the address being set.
     * @param oldAddress The old address.
     * @param newAddress The new address.
     */
    event AddressSet(
        address indexed executedBy,
        bytes32 id,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @notice Emitted when an address is set for a specific purpose.
     * @param executedBy The address that executed the action of setting the address.
     * @param role The hash of the role being destroyed
     */
    event RoleDestroyed(address indexed executedBy, bytes32 role);

    /**
     * @notice Emitted when the protocol upgradeability is disabled
     * @param executedBy The address that executed the action of disabling the upgradeability
     */
    event UpgradeabilityStopped(address indexed executedBy);

    /**
     * @notice Sets an address for an id replacing the address saved in the addresses map
     * IMPORTANT Use this function carefully, as it will do a hard replacement
     * @param _id The id
     * @param _newAddress The address to set
     */
    function setAddressForId(bytes32 _id, address _newAddress) external;

    /**
     * @notice Updates the LendingPool setting the new `pool` on the first time calling it
     * @dev Revokes the role from the previous address and grants it to the new address
     * @param _pool The new LendingPool
     */
    function setLendingPool(address _pool) external;

    /**
     * @notice Updates the  LendingPoolConfigurator setting the new `configurator` on the first time calling it
     * @dev Revokes the role from the previous address and grants it to the new address
     * @param _configurator The new LendingPoolConfigurator
     */
    function setLendingPoolConfigurator(address _configurator) external;

    /**
     * @notice Updates the address of the MeldProtocolDataProvider
     * @param _dataProvider The new MeldProtocolDataProvider address
     */
    function setProtocolDataProvider(address _dataProvider) external;

    /**
     * @notice Updates the address of the PriceOracle
     * @param _priceOracle The new PriceOracle address
     */
    function setPriceOracle(address _priceOracle) external;

    /**
     * @notice Updates the address of the LendingRateOracle
     * @param _lendingRateOracle The new LendingRateOracle address
     */
    function setLendingRateOracle(address _lendingRateOracle) external;

    /**
     * @notice  ADMIN: Sets the address of the MELD Banker NFT contract
     * @param   _meldBankerNFT  Address of the MELD Banker NFT contract
     */
    function setMeldBankerNFT(address _meldBankerNFT) external;

    /**
     * @notice  ADMIN: Sets the address of the MELD Banker NFT Minter contract
     * @param   _meldBankerNFTMinter  Address of the MELD Banker NFT contract
     */
    function setMeldBankerNFTMinter(address _meldBankerNFTMinter) external;

    /**
     * @notice  ADMIN: Sets the address of the YieldBoostFactory contract
     * @param   _yieldBoostFactory  Address of the YieldBoostFactory contract
     */
    function setYieldBoostFactory(address _yieldBoostFactory) external;

    /**
     * @notice  ADMIN: Sets the address of the MELD Token contract
     * @param   _meldToken  Address of the MELD Token contract
     */
    function setMeldToken(address _meldToken) external;

    /**
     * @notice  ADMIN: Sets the address of the MELD Staking Storage contract
     * @param   _meldStakingStorage  Address of the MELD Staking Storage contract
     */
    function setMeldStakingStorage(address _meldStakingStorage) external;

    /**
     * @notice Pauses the protocol
     * @dev This function can only be called by the `PAUSER_ROLE`
     */
    function pause() external;

    /**
     * @notice Unpauses the protocol
     * @dev This function can only be called by the `UNPAUSER_ROLE`
     */
    function unpause() external;

    /**
     * @notice Once called, prevents any future upgrades to the contracts
     * @dev This function can only be called by the `DEFAULT_ADMIN_ROLE`
     * @dev Upgradeability can be stopped after 6 months
     * @dev This action is not reversible
     */
    function stopUpgradeability() external;

    /**
     * @notice Destroys a role so that it can no longer be used and sets the admin for the role to 0x00.
     *  Only applicable to certain roles
     *  IMPORTANT Use this function carefully
     * @dev Only callable by the `DESTROYER_ROLE. If the role still have members, revoke the role for those members first.
     * @param _role The role to be destroyed
     */
    function destroyRole(bytes32 _role) external;

    /**
     * @notice Sets `adminRole` as ``role``'s admin role.
     * @dev Only callable by the `DEFAULT_ADMIN_ROLE`
     * @param _role The role to set the admin for
     * @param _adminRole The role to be set as admin
     */
    function setRoleAdmin(bytes32 _role, bytes32 _adminRole) external;

    /**
     * @notice  Checks if `account` has been granted `role`. If not, reverts with a string message that includes the hexadecimal representation of `role`.
     * @param   _role The role to check
     * @param   _account The account to check if it has the role
     */
    function checkRole(bytes32 _role, address _account) external view;

    /**
     * @notice  Checks if `role` has been destroyed
     * @param   _role The role to check
     * @return True if the role has been destroyed
     */
    function isDestroyedRole(bytes32 _role) external view returns (bool);

    /**
     * @notice Reverts if the protocol is paused.
     */
    function requireNotPaused() external view;

    /**
     * @notice Returns true if the upgradeable contracts can be upgraded
     * @dev Upgradeability can be stopped after 6 months
     * @return True if the contracts can be upgraded
     */
    function isUpgradeable() external view returns (bool);

    /**
     * @notice Returns an address by id
     * @return The address
     */
    function getAddressForId(bytes32 _id) external view returns (address);

    /**
     * @notice Returns the address of the LendingPool proxy
     * @return The LendingPool proxy address
     */
    function getLendingPool() external view returns (address);

    /**
     * @notice Returns the address of the LendingPoolConfigurator
     * @return The LendingPoolConfigurator address
     */
    function getLendingPoolConfigurator() external view returns (address);

    /**
     * @notice Returns the address of the MeldProtocolDataProvider
     * @return The address of the MeldProtocolDataProvider
     */
    function getProtocolDataProvider() external view returns (address);

    /**
     * @notice Returns the address of the PriceOracleAggregator
     * @return The address of the PriceOracleAggregator
     */
    function getPriceOracle() external view returns (address);

    /**
     * @notice Returns the address of the LendingRateOracleAggregator
     * @return The LendingRateOracleAggregator address
     */
    function getLendingRateOracle() external view returns (address);

    /**
     * @notice Returns the address of the MeldBankerNFT
     * @return The MeldBankerNFT address
     */
    function getMeldBankerNFT() external view returns (address);

    /**
     * @notice Returns the address of the MeldBankerNFTMinter
     * @return The MeldBankerNFTMinter address
     */
    function getMeldBankerNFTMinter() external view returns (address);

    /**
     * @notice Returns the address of the YieldBoostFactory
     * @return The YieldBoostFactory address
     */
    function getYieldBoostFactory() external view returns (address);

    /**
     * @notice Returns the address of the MeldToken
     * @return The MeldToken address
     */
    function getMeldToken() external view returns (address);

    /**
     * @notice Returns the address of the MeldStakingStorage
     * @return The MeldStakingStorage address
     */
    function getMeldStakingStorage() external view returns (address);

    /**
     * @notice  Returns the POOL_ADMIN_ROLE
     * @dev The POOL_ADMIN_ROLE allows for the execution of all the pool administrative tasks
     * @return  The POOL_ADMIN_ROLE
     */
    function POOL_ADMIN_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the LENDING_POOL_CONFIGURATOR_ROLE
     * @dev The LENDING_POOL_CONFIGURATOR_ROLE is the role that the LendingPoolConfigurator contract has been granted
     * @return  The LENDING_POOL_CONFIGURATOR_ROLE
     */
    function LENDING_POOL_CONFIGURATOR_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the LENDING_POOL_ROLE
     * @dev The LENDING_POOL_ROLE is the role that the LendingPool contract has been granted
     * @return  The LENDING_POOL_ROLE
     */
    function LENDING_POOL_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Exposes the DEFAULT_ADMIN_ROLE
     * @dev The DEFAULT_ADMIN_ROLE allows for the execution of all the protocol administrative tasks
     * @return  The DEFAULT_ADMIN_ROLE
     */
    function PRIMARY_ADMIN_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the ORACLE_MANAGEMENT_ROLE
     * @dev The ORACLE_MANAGEMENT_ROLE allows for the execution of all the oracle administrative tasks
     * @return  The ORACLE_MANAGEMENT_ROLE
     */
    function ORACLE_MANAGEMENT_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the BNKR_NFT_MINTER_BURNER_ROLE
     * @dev The BNKR_NFT_MINTER_BURNER_ROLE allows for the execution of all the oracle administrative tasks
     * @return  The BNKR_NFT_MINTER_BURNER_ROLE
     */
    function BNKR_NFT_MINTER_BURNER_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the YB_REWARDS_SETTER_ROLE
     * @dev The YB_REWARDS_SETTER_ROLE allows for the setting of rewards in the different instances of YieldBoostTreasury
     * @return  The YB_REWARDS_SETTER_ROLE
     */
    function YB_REWARDS_SETTER_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the GENIUS_LOAN_ROLE
     * @dev The GENIUS_LOAN_ROLE allows for the execution of all genius loan tasks
     * @return  The GENIUS_LOAN_ROLE
     */
    function GENIUS_LOAN_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the PAUSER_ROLE
     * @dev The PAUSER_ROLE allows for the execution of all yield boost tasks
     * @return  The PAUSER_ROLE
     */
    function PAUSER_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the UNPAUSER_ROLE
     * @dev The UNPAUSER_ROLE allows for the execution of all yield boost tasks
     * @return  The UNPAUSER_ROLE
     */
    function UNPAUSER_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice  Returns the DESTROYER_ROLE
     * @dev The DESTROYER_ROLE can destroy a role. This means it can make it so that no one can have that role.
     * @return  DESTROYER_ROLE
     */
    function DESTROYER_ROLE() external pure returns (bytes32); // solhint-disable-line func-name-mixedcase
}
