import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();
import './tasks/accounts';
import "./tasks/block-number";


const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL!;
const PRIVATE_KEY = process.env.PRIVATE_KEY!;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY!;

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
      chainId: 31337
      // no need to pass accounts here it's automatically done by hardhat
    }
  },
  solidity: "0.8.9",
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
// yarn hardhat node
// run a local node

export default config;
