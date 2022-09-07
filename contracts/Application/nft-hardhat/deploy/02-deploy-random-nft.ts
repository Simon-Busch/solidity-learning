import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import verify from "../utils/verify";
import {
    developmentChains,
    networkConfig,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} from "../helper-hardhat-config";
import { ethers } from "hardhat";
import { storeImages, storeTokeUriMetadata } from "../utils/uploadToPinata";
import { string } from "hardhat/internal/core/params/argumentTypes";

const imagesLocation = "./images/randomNft/";

const metaDataTemplate = {
  name: "",
  description: "",
  image: "",
  attributes: [
    {
      trait_type: "rarity",
      value: 100
    }
  ]
}

const FUND_AMOUNT = "1000000000000000000000";

const deployRandomNft: DeployFunction = async (
    hre: HardhatRuntimeEnvironment
) => {
    const { getNamedAccounts, deployments, network } = hre;
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId: number = network.config.chainId!;
    let tokenUris: string[] = [
      'ipfs://QmRuXbzL4iaqwioHKudpRuFZZqbEDpRjPNeBeSfzNrGVpy',
      'ipfs://QmTm3UYPJvgSi9mSM6yRYEfWtzHwB3tdojUn51coXYFMyr',
      'ipfs://QmP5sb8eHBwhXdRe8EKLm835QPunaDyUGcZ9mGKD7ACpgH'
    ];
    // get IPFS hashes of our images

    if (process.env.UPLOAD_TO_PINATA === "true") {
        tokenUris = await handleTokenUris();
    }
    //1. With our own ipfs node
    //2. Pinata https://www.pinata.cloud/
    //3. Nft.storage https://nft.storage/

    log("----------------------------------");
    let vrfCoordinatorV2Address, subscriptionId;
    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract(
            "VRFCoordinatorV2Mock"
        );
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
        const tx = await vrfCoordinatorV2Mock.createSubscription();
        const txReceipt = await tx.wait(1);
        subscriptionId = txReceipt.events[0].args.subId;
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT);
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2;
        subscriptionId = networkConfig[chainId].subscriptionId;
    }

    log("----------------------------------");

    const args = [
        vrfCoordinatorV2Address,
        subscriptionId,
        networkConfig[chainId].gasLane,
        networkConfig[chainId].callbackGasLimit,
        tokenUris!,
        networkConfig[chainId].mintFee,
      ];

      const randomIpfsNft = await deploy("RandomIpfsNft", {
        from: deployer,
        args:args,
        log:true,
        waitConfirmations: 1
      })

      log("----------------------------------");

      if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying ...");
        await verify(randomIpfsNft.address, args);
      }
};
export default deployRandomNft;
deployRandomNft.tags = ["all", "randomipfs", "main"];


async function handleTokenUris() {
  // Check out https://github.com/PatrickAlphaC/nft-mix for a pythonic version of uploading
  // to the raw IPFS-daemon from https://docs.ipfs.io/how-to/command-line-quick-start/
  // You could also look at pinata https://www.pinata.cloud/
  let tokenUris = []
  const { responses: imageUploadResponses, files } = await storeImages(imagesLocation)
  for (const imageUploadResponseIndex in imageUploadResponses) {
      let tokenUriMetadata = { ...metaDataTemplate }
      tokenUriMetadata.name = files[imageUploadResponseIndex].replace(".png", "")
      tokenUriMetadata.description = `An adorable ${tokenUriMetadata.name} pup!`
      tokenUriMetadata.image = `ipfs://${imageUploadResponses[imageUploadResponseIndex].IpfsHash}`
      console.log(`Uploading ${tokenUriMetadata.name}...`)
      const metadataUploadResponse = await storeTokeUriMetadata(tokenUriMetadata)
      tokenUris.push(`ipfs://${metadataUploadResponse!.IpfsHash}`)
  }
  console.log("Token URIs uploaded! They are:")
  console.log(tokenUris)
  return tokenUris
}
