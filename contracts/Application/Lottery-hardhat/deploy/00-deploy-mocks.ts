import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { developmentChains, networkConfig } from "../helper-hardhat-config";
import { ethers } from "hardhat";

const BASE_FEE = ethers.utils.parseEther("0.25"); // 0.25 is the prenium, it costs 0.25 LINK
// calculated value based on gas price of the chain
const GAS_PRICE_LINK = 1e9; // link per gas, is this the gas lane? // 0.000000001 LINK per gas

const deployMocks: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    // @ts-ignore
    const { getNamedAccounts, deployments, network } = hre;
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const args = [BASE_FEE, GAS_PRICE_LINK];

    if (developmentChains.includes(network.name)) {
        log("Local network detected! deploying mocks....");
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: args,
        });
        log("Mocks Deployed!");
        log("----------------------------------");

        log(
            "You are deploying to a local network, you'll need a local network running to interact"
        );
        log(
            "Please run `yarn hardhat console --network localhost` to interact with the deployed smart contracts!"
        );
        log("----------------------------------");
    }
};
export default deployMocks;
deployMocks.tags = ["all", "mocks"];
