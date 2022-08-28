import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { developmentChains, networkConfig } from "../helper-hardhat-config";
import { ethers } from "hardhat";
import { verify } from "../utils/verify";

const VRF_SUB_FUND_AMOUNT = ethers.utils.parseEther("30"); // way too much

const deployLottery: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    // @ts-ignore
    const { getNamedAccounts, deployments, network } = hre;
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId!;

    let waitConfirmations;
    if (network.name === "goerli") {
        waitConfirmations = 5;
    } else {
        waitConfirmations = 1;
    }

    let vrfCoordinatorV2Address, subscriptionId;

    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract(
            "VRFCoordinatorV2Mock"
        );
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
        const transactionResponse =
            await vrfCoordinatorV2Mock.createSubscription();
        const transactionReceipt = await transactionResponse.wait(1);
        subscriptionId = transactionReceipt.events[0].args.subId;
        // fund subscription
        //usually you'd need the link token on a real token
        await vrfCoordinatorV2Mock.fundSubscription(
            subscriptionId,
            VRF_SUB_FUND_AMOUNT
        );
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"];
        subscriptionId = networkConfig[chainId]["subscriptionId"];
    }

    const entranceFee = networkConfig[chainId]["entranceFee"];
    const gasLane = networkConfig[chainId]["gasLane"];
    const callbackGasLimit = networkConfig[chainId]["callbackGasLimit"];
    const keepersUpdateInterval =
        networkConfig[chainId]["keepersUpdateInterval"];
    const args = [
        vrfCoordinatorV2Address,
        entranceFee,
        gasLane,
        subscriptionId,
        callbackGasLimit,
        keepersUpdateInterval,
    ];

    const lottery = await deploy("Lottery", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: waitConfirmations,
    });

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("Verifying ...");
        await verify(lottery.address, args);
    }

    log("--------------------------------------------------");
};
export default deployLottery;
deployLottery.tags = ["all", "lottery"];

// RUN with yarn hardhat deploy --network XXXXX
