import { ethers, getNamedAccounts, network } from "hardhat";
import { networkConfig } from "../helper-hardhat-config";
export const AMOUNT = ethers.utils.parseEther("0.1").toString();

export async function getWeth() {
    const { deployer } = await getNamedAccounts();
    const chainid = network.config.chainId;
    // call the "deposit" function on the weth contract
    // need abi && contract address
    // 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    // NB: address from mainnet
    // can use thanks for the hardhat config forking the mainnet blockchain
    const iWeth = await ethers.getContractAt(
        "IWeth",
        networkConfig[chainid!].wethToken!,
        deployer
    );
    await iWeth.deposit({ value: AMOUNT });
    const wethBalance = await iWeth.balanceOf(deployer);
    console.log(`Got ${wethBalance.toString()} WETH`);
}
