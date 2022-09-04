import { ethers, getNamedAccounts, network } from "hardhat";
import { networkConfig } from "../helper-hardhat-config";
import { Address } from "hardhat-deploy/dist/types";
import { BigNumber } from "ethers";
import { getWeth, AMOUNT } from "./getWeth";
import { ILendingPool } from "../typechain-types/index";

async function main() {
    /** 1. Deposit collateral ETH / WETH */
    // the protocol treats everything as an ERC20 token
    await getWeth();
    const { deployer } = await getNamedAccounts();

    const lendingPool = await getLendingPool(deployer);
    console.log(`LendingPool address = ${lendingPool.address}`);

    //deposit
    const wethTokenAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

    //approve
    await approveERC20(wethTokenAddress, lendingPool.address, AMOUNT, deployer);
    // !! important to approve first before deposit
    console.log("depositing ...");
    await lendingPool.deposit(wethTokenAddress, AMOUNT, deployer, 0);
    console.log("Deposited ✅");

    /**2. Borrow another asset: DAI */
    // How much we have borrowed ?
    // How much we have in collateral ?
    // How much we can borrow ?
    // https://docs.aave.com/developers/v/2.0/the-core-protocol/lendingpool#getuseraccountdata
    // interesting reading: https://docs.aave.com/developers/v/2.0/guides/liquidations
    let {availableBorrowsETH, totalDebtETH} = await getBorrowUserData(lendingPool, deployer);

    // What is the convertion rate with DAI ?
    const daiPrice = await getDaiPrice()
}

async function getDaiPrice () {
  // 0x773616E4d11A78F511299002da57A0a94577F1f4 DAI/ETH Mainnet https://docs.chain.link/docs/ethereum-addresses/
  const daiEthPriceFeed = await ethers.getContractAt("AggregatorV3Interface", "0x773616E4d11A78F511299002da57A0a94577F1f4");
  // no need to connect it to the deployer account as we won't be sending transactions
  // reading don't need a signer
  const price = (await daiEthPriceFeed.latestRoundData())[1]; // [1] as we just need the price returned here in the available datas
  console.log(`The DAI/ETH Price is ${price.toString()}`)
  return price;
}

async function getBorrowUserData(lendingPool: any, account: string) {
    const { totalCollateralETH, totalDebtETH, availableBorrowsETH } =
        await lendingPool.getUserAccountData(account);
    console.log(`You have ${totalCollateralETH} worth of ETH`);
    console.log(`You Have a total debt of ${totalDebtETH} woth of ETH`);
    console.log(`You can borrow: ${availableBorrowsETH}`);
    return { totalDebtETH, availableBorrowsETH };
}

async function approveERC20(
    erc20Address: string,
    spenderAddress: string,
    amountToSpend: string,
    account: string
) {
    const erc20Token = await ethers.getContractAt(
        "IERC20",
        erc20Address,
        account
    );

    const tx = await erc20Token.approve(spenderAddress, amountToSpend);
    await tx.wait(1);
    console.log("Approved");
}

async function getLendingPool(account: string) {
    // Address : 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5
    // https://docs.aave.com/developers/v/2.0/deployed-contracts/deployed-contracts
    const lendingPoolAddressesProvider = await ethers.getContractAt(
        "ILendingPoolAddressesProvider", // no need to define it as interface as it's imported from node_module
        "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5",
        account
    );
    const lendingPoolAddress =
        await lendingPoolAddressesProvider.getLendingPool();
    const lendingPool = await ethers.getContractAt(
        "ILendingPool",
        lendingPoolAddress,
        account
    );
    return lendingPool;
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
