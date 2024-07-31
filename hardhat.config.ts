import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

dotenv.config();

const MUMBAI_PRIVATE_KEY = process.env.MUMBAI_PRIVATE_KEY;
const FUJI_PRIVATE_KEY = process.env.FUJI_PRIVATE_KEY;
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;
const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;
const KANAZAWA_PRIVATE_KEY = process.env.KANAZAWA_PRIVATE_KEY;
const ETHEREUM_PRIVATE_KEY = process.env.ETHEREUM_PRIVATE_KEY;
const POLYGON_PRIVATE_KEY = process.env.POLYGON_PRIVATE_KEY;
const AVALANCHE_PRIVATE_KEY = process.env.AVALANCHE_PRIVATE_KEY;
const BINANCE_PRIVATE_KEY = process.env.BINANCE_PRIVATE_KEY;
const MELD_PRIVATE_KEY = process.env.MELD_PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      evmVersion: "shanghai",
    },
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545/",
      chainId: 31337,
    },
    ganache: {
      url: "http://127.0.0.1:7545/",
      chainId: 1337,
    },
    mumbai: {
      url: process.env.MUMBAI_RPC_URL || "https://rpc-mumbai.maticvigil.com",
      chainId: 80001,
      accounts: MUMBAI_PRIVATE_KEY ? [MUMBAI_PRIVATE_KEY] : "remote",
    },
    fuji: {
      url:
        process.env.FUJI_RPC_URL ||
        "https://api.avax-test.network/ext/bc/C/rpc",
      chainId: 43113,
      accounts: FUJI_PRIVATE_KEY ? [FUJI_PRIVATE_KEY] : "remote",
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL || "https://rpc.ankr.com/eth_goerli",
      chainId: 5,
      accounts: GOERLI_PRIVATE_KEY ? [GOERLI_PRIVATE_KEY] : "remote",
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "https://rpc.sepolia.org/",
      chainId: 11155111,
      accounts: SEPOLIA_PRIVATE_KEY ? [SEPOLIA_PRIVATE_KEY] : "remote",
    },
    kanazawa: {
      url:
        process.env.KANAZAWA_RPC_URL ||
        "https://subnets.avax.network/meld/testnet/rpc",
      chainId: 222000222,
      accounts: KANAZAWA_PRIVATE_KEY ? [KANAZAWA_PRIVATE_KEY] : "remote",
    },
    ethereum: {
      url:
        process.env.ETHEREUM_RPC_URL ||
        "https://meld:ta3jl1VXvjMpTXDdP1kl@meld-ethereum-mainnet.zeeve.net/rpc",
      chainId: 1,
      accounts: ETHEREUM_PRIVATE_KEY ? [ETHEREUM_PRIVATE_KEY] : "remote",
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL || "https://rpc-mainnet.maticvigil.com",
      chainId: 137,
      accounts: POLYGON_PRIVATE_KEY ? [POLYGON_PRIVATE_KEY] : "remote",
    },
    avalanche: {
      url:
        process.env.AVALANCHE_RPC_URL ||
        "https://avalanche-c-chain.publicnode.com	",
      chainId: 43114,
      accounts: AVALANCHE_PRIVATE_KEY ? [AVALANCHE_PRIVATE_KEY] : "remote",
    },
    binance: {
      url: process.env.BINANCE_RPC_URL || "https://bsc.publicnode.com",
      chainId: 56,
      accounts: BINANCE_PRIVATE_KEY ? [BINANCE_PRIVATE_KEY] : "remote",
    },
    meld: {
      url:
        process.env.MELD_RPC_URL ||
        "https://subnets.avax.network/meld/mainnet/rpc",
      chainId: 333000333,
      accounts: MELD_PRIVATE_KEY ? [MELD_PRIVATE_KEY] : "remote",
    },
  },
  sourcify: {
    enabled: true,
  },
  etherscan: {
    apiKey: {
      kanazawa: "api-key",
      meld: "api-key",
    },
    customChains: [
      {
        network: "kanazawa",
        chainId: 222000222,
        urls: {
          apiURL: "https://api-testnet.meldscan.io/api/",
          browserURL: "https://testnet.meldscan.io/",
        },
      },
      {
        network: "meld",
        chainId: 333000333,
        urls: {
          apiURL: "https://api.meldscan.io/api/",
          browserURL: "https://meldscan.io/",
        },
      },
    ],
  },
};

export default config;
