import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "typechain";
import "dotenv/config";
import "./tasks/accounts";
import "./tasks/block-number";
import "hardhat-gas-reporter";
import "solidity-coverage"; // check lines covered by tests -- yarn hardhat coverage

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL!;
const PRIVATE_KEY = process.env.PRIVATE_KEY!;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY!;
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY!;

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  //yarn hardhat run scripts/deploy.ts --network hardhat
  networks: {
    // yarn hardhat run scripts/deploy.ts --network goerli
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
    },
    locahost: {
      url: " http://127.0.0.1:8545/",
      chainId: 31337,
      // no need to pass accounts here it's automatically done by hardhat
    },
  },
  solidity: "0.8.9",
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  gasReporter: {
    // run with the tests
    enabled: true, // enable when needed
    // optionnal
    // output with different currencies possible
    outputFile: "gas-report.txt",
    noColors: true,
    currency: "USD",
    // coinmarketcap: COINMARKETCAP_API_KEY,
    token: "MATIC",
  },
};
// yarn hardhat node
// run a local node

export default config;
