import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { network, deployments, ethers } from "hardhat";
import { developmentChains } from "../../helper-hardhat-config";
import { getNamedAccounts } from "hardhat";
import { Contract, Signer, BigNumber } from "ethers";
import { networkConfig } from "../../helper-hardhat-config";
import { Lottery } from "../../typechain-types/contracts/Lottery";
import { VRFCoordinatorV2Mock } from "../../typechain-types/@chainlink/contracts/src/v0.8/mocks";
import { Provider } from "@ethersproject/abstract-provider";

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Testing Lottery", async function () {
          let lottery: Lottery,
              lotteryContract: Lottery,
              vrfCoordinatorV2Mock: VRFCoordinatorV2Mock,
              lotteryEntranceFee: BigNumber,
              interval: number,
              accounts: SignerWithAddress[],
              deployer: SignerWithAddress,
              player: SignerWithAddress;
          const chainId = network.config.chainId!;

          this.beforeEach(async () => {
              accounts = await ethers.getSigners(); // could also do with getNamedAccounts
              deployer = accounts[0];
              player = accounts[1];
              await deployments.fixture(["mocks", "lottery"]); // Deploys modules with the tags "mocks" and "lottery"
              vrfCoordinatorV2Mock = await ethers.getContract(
                  "VRFCoordinatorV2Mock"
              ); // Returns a new connection to the VRFCoordinatorV2Mock contract
              lotteryContract = await ethers.getContract("Lottery"); // Returns a new connection to the lottery contract
              lottery = lotteryContract.connect(player); // Returns a new instance of the lottery contract connected to player
              lotteryEntranceFee = await lottery.getEntranceFee();
              interval = (await lottery.getInterval()).toNumber();
          });

          describe("constructor", async function () {
              it("Initialize the lottery correctly", async function () {
                  const lotteryState = (
                      await lottery.getLotteryState()
                  ).toString();
                  assert.equal(lotteryState.toString(), "0");
                  assert.equal(
                      interval.toString(),
                      networkConfig[chainId]["keepersUpdateInterval"]
                  );
              });
          });

          describe("Enter Lottery", async function () {
              it("reverts when you don't pay enough", async () => {
                  await expect(
                      lottery.enterLottery()
                  ).to.be.revertedWithCustomError(
                      lottery,
                      "Lottery__SendMoreToEnterLottery"
                  );
              });

              it("reverts records player when they enter", async () => {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  const contractPlayer = await lottery.getPlayer(0);
                  assert.equal(player.address, contractPlayer);
              });

              //testing events
              it("Emits event on enter", async function () {
                  await expect(
                      lottery.enterLottery({ value: lotteryEntranceFee })
                  ).to.emit(lottery, "LotteryEnter");
              });

              it("Does not allow lottery if lottery is calculating", async () => {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  // manipulating the network :https://hardhat.org/hardhat-network/docs/reference#json-rpc-methods-support
                  await network.provider.send("evm_increaseTime", [
                      interval + 1,
                  ]); // manipulate time of the blockchain
                  await network.provider.send("evm_mine", []); // mine an extra block
                  //pretend to be a chainlink keeper
                  // fake the state of LotteryState.CALCULATING
                  await lottery.performUpkeep([]);
                  await expect(
                      lottery.enterLottery({ value: lotteryEntranceFee })
                  ).to.be.revertedWithCustomError(
                      lottery,
                      "Lottery__LoteryNotOpen"
                  );
              });
          });

          describe("Check upkeep", async function () {
              it("returns false if people have not send any ETH", async () => {
                  await network.provider.send("evm_increaseTime", [
                      interval + 1,
                  ]); // manipulate time of the blockchain
                  await network.provider.send("evm_mine", []); // mine an extra block
                  // await lottery.checkUpkeep([]); // kicks off a transaction because it's not a view function
                  const { upKeepNeeded } = await lottery.callStatic.checkUpkeep(
                      []
                  ); //callstatic simulate calling this transaction and see response
                  assert(!upKeepNeeded);
              });
          });
      });
