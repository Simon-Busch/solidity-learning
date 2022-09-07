import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-deploy";
import "dotenv/config";


const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL!;
const PRIVATE_KEY = process.env.PRIVATE_KEY!;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY!;
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY!;
const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL!;
// mainnet forking: https://hardhat.org/hardhat-network/docs/guides/forking-other-networks

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
    },
    hardhat: {
      chainId: 31337,
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${MAINNET_RPC_URL}`,
      }
    },
  },
  solidity: {
    compilers: [
      {version: "0.8.9"},
      {version: "0.4.19"},
      {version: "0.6.0"},
      {version: "0.6.6"},
      {version: "0.6.12"}
    ]
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: true,
    outputFile: "gas-report.txt",
    noColors: true,
    currency: "USD",
    coinmarketcap: COINMARKETCAP_API_KEY,
    token: "MATIC",
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    player: {
      default: 1,
    }
  },
  mocha: { // set timout for tests
    timeout: 500000, // 200 seconds max for running tests
  }
};

export default config;
