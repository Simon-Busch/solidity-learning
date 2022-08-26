import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { assert, expect } from "chai"
import { network, deployments, ethers } from "hardhat"
import { developmentChains } from "../../helper-hardhat-config"
import { FundMe, MockV3Aggregator } from "../../typechain-types"

describe("Fund Me", async function () {
  let fundMe: FundMe;
  let mockV3Aggregator: MockV3Aggregator
  let deployer: SignerWithAddress
  const sendValue = ethers.utils.parseEther("1");

  this.beforeEach(async function () {
    if (!developmentChains.includes(network.name)) {
      throw "You need to be on a development chain to run tests"
    }

    const accounts = await ethers.getSigners()
    deployer = accounts[0]
    await deployments.fixture(["all"])
    // allows us to run our deploy folder with the tags "all"
    fundMe = await ethers.getContract("FundMe");
    mockV3Aggregator = await ethers.getContract("MockV3Aggregator");
  })

  describe("Constructor --", async function () {
    it("set the aggregator address correctly", async function () {
      const response = await fundMe.getPriceFeed();
      assert.equal(response, mockV3Aggregator.address)
    })
  })

  describe("Fund --", async function () {
    it("fails if you don't send enough ETH", async function () {
      await expect(fundMe.fund()).to.be.revertedWith("Didn't send enough ETH")
    })
    it("updated the amount funded data structure", async function () {
      await fundMe.fund({value: sendValue});
      const response = await fundMe.getAddressToAmountFunded(deployer.address);
      assert.equal(response.toString(), sendValue.toString())
    })
    it("adds funder to array of funders", async function () {
      await fundMe.fund({value: sendValue});
      const funder = await fundMe.getFunder(0);
      assert.equal(funder, deployer.address);
    })
  })
  describe("Withdraw --", async function () {
    this.beforeEach(async function () {
      await fundMe.fund({value: sendValue});
    })
    it("Can withdraw ETH from a single funder", async function () {
      // could use ethers.provider instead of fundMe.provider
      const startingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const startingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      const transactionResponse = await fundMe.withdraw();
      const transactionReceipt = await transactionResponse.wait(1);

      const { gasUsed, effectiveGasPrice } = transactionReceipt
      //mul comes from bigNumber ( ethers )
      const gasCost = gasUsed.mul(effectiveGasPrice)

      const endingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const endingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      assert.equal(endingFundMeBalance.toString(), "0")
      assert.equal(
        startingFundMeBalance.add(startingDeployerBalance).toString(),
        endingDeployerBalance.add(gasCost).toString()
      )
    })

    // run only this test : yarn hardhat test --grep "withdraw with multiple funders"
    it("Allows us to withdraw with multiple funders", async function() {
      const accounts = await ethers.getSigners();

      for(let i = 1; i < 6 ; i++) {
        const fundMeConnectedContract = await fundMe.connect(accounts[i]);
        await fundMeConnectedContract.fund({value: sendValue});
      }

      const startingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const startingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      const transactionResponse = await fundMe.withdraw();
      const transactionReceipt = await transactionResponse.wait(1);
      const { gasUsed, effectiveGasPrice } = transactionReceipt
      //mul comes from bigNumber ( ethers )
      const gasCost = gasUsed.mul(effectiveGasPrice)

      const endingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const endingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      assert.equal(endingFundMeBalance.toString(), "0")
      assert.equal(
        startingFundMeBalance.add(startingDeployerBalance).toString(),
        endingDeployerBalance.add(gasCost).toString()
      )

      // make sure the funders are reset properly
      await expect(fundMe.getFunder(0)).to.be.reverted;

      for (let i=1; i< 6; i ++) {
        assert.equal((await fundMe.getAddressToAmountFunded(accounts[i].address)).toString(), '0')
      }
    })

    // it('Only allows the owner to withdraw', async function() {
    //   const accounts = await ethers.getSigners();
    //   const attacker = accounts[1]
    //   const attackerConnectedContract = await fundMe.connect(attacker.address);
    //   console.log(attackerConnectedContract)
    //   await expect(attackerConnectedContract.withdraw()).to.be.revertedWith("FundMe__NotOwner");
    // })
  })


  describe("Cheaper Withdraw testing --", async function () {
    this.beforeEach(async function () {
      await fundMe.fund({value: sendValue});
    })
    it("Can withdraw ETH from a single funder", async function () {
      // could use ethers.provider instead of fundMe.provider
      const startingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const startingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      const transactionResponse = await fundMe.cheaperWithdraw();
      const transactionReceipt = await transactionResponse.wait(1);

      const { gasUsed, effectiveGasPrice } = transactionReceipt
      //mul comes from bigNumber ( ethers )
      const gasCost = gasUsed.mul(effectiveGasPrice)

      const endingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const endingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      assert.equal(endingFundMeBalance.toString(), "0")
      assert.equal(
        startingFundMeBalance.add(startingDeployerBalance).toString(),
        endingDeployerBalance.add(gasCost).toString()
      )
    })

    // run only this test : yarn hardhat test --grep "withdraw with multiple funders"
    it("Allows us to withdraw with multiple funders", async function() {
      const accounts = await ethers.getSigners();

      for(let i = 1; i < 6 ; i++) {
        const fundMeConnectedContract = await fundMe.connect(accounts[i]);
        await fundMeConnectedContract.fund({value: sendValue});
      }

      const startingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const startingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      const transactionResponse = await fundMe.cheaperWithdraw();
      const transactionReceipt = await transactionResponse.wait(1);
      const { gasUsed, effectiveGasPrice } = transactionReceipt
      //mul comes from bigNumber ( ethers )
      const gasCost = gasUsed.mul(effectiveGasPrice)

      const endingFundMeBalance = await fundMe.provider.getBalance(fundMe.address);
      const endingDeployerBalance = await fundMe.provider.getBalance(deployer.address);

      assert.equal(endingFundMeBalance.toString(), "0")
      assert.equal(
        startingFundMeBalance.add(startingDeployerBalance).toString(),
        endingDeployerBalance.add(gasCost).toString()
      )

      // make sure the funders are reset properly
      await expect(fundMe.getFunder(0)).to.be.reverted;

      for (let i=1; i< 6; i ++) {
        assert.equal((await fundMe.getAddressToAmountFunded(accounts[i].address)).toString(), '0')
      }
    })
  })
  describe("Fallback --", async function () {

  })
  describe("Receive --", async function () {

  })
});
