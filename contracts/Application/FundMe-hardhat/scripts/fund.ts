import { ethers, getNamedAccounts, deployments } from "hardhat"

async function main() {
  //yarn hardhat run scripts/fund.ts --network goerli
  const { deployer } = await getNamedAccounts()
  const fundMe = await ethers.getContract("FundMe", deployer)
  console.log(`Got contract FundMe at ${fundMe.address}`)
  console.log("Funding contract...")
  const transactionResponse = await fundMe.fund({
    value: ethers.utils.parseEther("0.05"),
  })
  await transactionResponse.wait()
  console.log("Funded!")
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
