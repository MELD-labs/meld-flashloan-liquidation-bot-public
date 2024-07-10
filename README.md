# MELD Flashloan liquidation bot Example

This repo contains the contracts and offchain systems needed to run a liquidation bot for the MELD lending and borrowing protocol.

The contracts are written in Solidity, and the bot in Python.

To configure the bot, create a `.env` file following the example of `.sample.env` filling the details for configuration.

The bot and contracts are provided as refference, but we encourage you to extend them and ensure they work following your desired flows. Do not trust the contracts and scripts in this repo blidly, DYOR.

## Solidity contracts

The repo has a standard Hardhat project where you can work and compile your contracts. The main contract in this project is `LiquidateLoan.sol`. The contract is well documented and flows are explained in the solidity file.

run `yarn` to install dependencies

To deploy your own version of the bot, run the command

```
yarn hardhat run scripts/deploy.ts --network <network>
```

The network configuration is in the `hardhat.config.ts` file. You can add or modify networks there. There is a `.sample.env` file that you can use as a template to create a `.env` file with the private keys of the accounts you want to interact with the different networks. You can also configure a different RPC URL for each network, as well as set your own `ETHERSCAN_API_KEY`.

To verify contracts on many explorers, you need to set the appropriate `ETHERSCAN_API_KEY` env var and run the following command:

```
yarn hardhat verify --network <network> <contract address> <constructor arguments>
```

## Offchain bot

The bot is written in Python in the folder `./offchain-bot ` .

To execute, ensure you have all the dependencies installed and then compile the contracts to get the ABIs:

```
yarn compile
```

Then you can run the bot with the command:

```
python offchain-bot/main.py
```

The bot reads from MELD's API the list of accounts in a liquidatable state, and leverages flashloans and a univ2 exchange (Azomi) to:

- Take a flashloan of the debt asset
- Liquidate that asset and receive a collateral asset from the user
- Swap the collateral asset into the asset to pay the flashloan into
- Check that there is enough money for the full transaction to happen
- Send the benefit to the treasury, and repay the flashloan
