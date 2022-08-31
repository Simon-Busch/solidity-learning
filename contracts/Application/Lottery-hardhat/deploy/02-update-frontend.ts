
import { frontEndContractsFile, frontEndAbi } from "../helper-hardhat-config"
import fs from "fs"
import {DeployFunction} from "hardhat-deploy/types"
import {HardhatRuntimeEnvironment} from "hardhat/types"

const updateUI: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
  ) {

    if (process.env.UPDATE_FRONT_END) {
        console.log("Writing to front end...")
        await updateContractAddress(hre)
        await updateAbi(hre);
        console.log("Front end written!")
    }
}

const updateContractAddress = async (hre: HardhatRuntimeEnvironment) => {
  const { network, ethers } = hre
  const chainId = network.config.chainId || "31337"
  const lottery = await ethers.getContract("Lottery")
  const contractAddresses = JSON.parse(fs.readFileSync(frontEndContractsFile, "utf8"))
  if (chainId in contractAddresses) {
      if (!contractAddresses[network.config.chainId!].includes(lottery.address)) {
          contractAddresses[network.config.chainId!].push(lottery.address)
      }
  } else {
      contractAddresses[network.config.chainId!] = [lottery.address]
  }
  fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses))
}

const updateAbi = async (hre: HardhatRuntimeEnvironment) => {
  const { ethers } = hre
  const lottery = await ethers.getContract("Lottery")
  //@ts-ignore
  fs.writeFileSync(frontEndAbi, lottery.interface.format(ethers.utils.FormatTypes.json))
}
export default updateUI
updateUI.tags = ["all", "frontend"]
