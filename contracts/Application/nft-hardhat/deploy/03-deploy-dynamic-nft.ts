import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import verify from "../utils/verify";
import { developmentChains, networkConfig } from "../helper-hardhat-config";
import { ethers } from "hardhat";
import fs from "fs";

const deployDynamicNft: DeployFunction = async (
    hre: HardhatRuntimeEnvironment
) => {
    const { getNamedAccounts, deployments, network } = hre;
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId: number = network.config.chainId!;
    let ethUsdPriceFeedAddress;

    if (developmentChains.includes(network.name)) {
        const EthUsdAggregator = await ethers.getContract("MockV3Aggregator");
        ethUsdPriceFeedAddress = EthUsdAggregator.address;
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed;
    }

    const waitBlockConfirmations = 1;

    const lowSVG = fs.readFileSync("./images/dynamicNft/frown.svg", {
        encoding: "utf8",
    });
    const highSVG = fs.readFileSync("./images/dynamicNft/happy.svg", {
        encoding: "utf8",
    });

    log("----------------------------------------------------");
    const args = [ethUsdPriceFeedAddress, lowSVG, highSVG];
    const dynamicSvgNft = await deploy("DynamicSvgNft", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: waitBlockConfirmations || 1,
    });

    // Verify the deployment
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("Verifying...");
        await verify(dynamicSvgNft.address, args);
    }
};

export default deployDynamicNft;
deployDynamicNft.tags = ["all", "dynamicnft", "main"];
