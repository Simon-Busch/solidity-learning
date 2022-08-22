import { ethers, run, network } from "hardhat";
//hardhat comes built in with Hardhat network
async function main() {
  const SimpleStorageFactory = await ethers.getContractFactory("SimpleStorage");
  console.log("deploying contract ...");
  const simpleStorage = await SimpleStorageFactory.deploy();
  await simpleStorage.deployed();
  console.log(`Deployed contract to: ${simpleStorage.address}`);

  // check if live network ( not hardhat network )
  // console.log (network.config)
  // check for goerli network
  if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
    await simpleStorage.deployTransaction.wait(6)
    // best practice to wait for a few block to be mined to make sure data are on etherscan
    await verify(simpleStorage.address, [])
  } else {
    console.log('wrong network, use Goerli')
  }

  const currentValue = await simpleStorage.retrieve();
  console.log(`current value is: ${currentValue}`);
  const transactionResponse = await simpleStorage.store('7');
  await transactionResponse.wait(1)
  const updatedValue = await simpleStorage.retrieve();
  console.log(`updated value is: ${updatedValue}`)
}

async function verify(contractAddress: string, args?: any[]) {
  console.log("Verifying contract ...");

  try {
    // "run" allow to run hardhat tasks
    await run("verify:verify", {
      address: contractAddress,
      contructorArguments: args,
    });
  } catch (err: any) {
    if (err.message.toLowerCase().includes("already verified")) {
      console.log("already verified");
    } else {
      console.log(err);
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
