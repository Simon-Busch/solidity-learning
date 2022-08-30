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
    : describe("Testing Lottery", function() {
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

          describe("constructor", function() {
              it("Initialize the lottery correctly", async function() {
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

          describe("Enter Lottery", function() {
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
              it("Emits event on enter", async function() {
                  await expect(
                      lottery.enterLottery({ value: lotteryEntranceFee })
                  ).to.emit(lottery, "LotteryEnter");
              });

              it("Does not allow lottery if lottery is calculating", async () => {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  // manipulating the network :https://hardhat.org/hardhat-network/docs/reference#json-rpc-methods-support
                  await network.provider.send("evm_increaseTime", [
                      interval + 1
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

          describe("Check upkeep", function() {
              it("returns false if people have not send any ETH", async () => {
                  await network.provider.send("evm_increaseTime", [
                      interval + 1
                  ]); // manipulate time of the blockchain
                  await network.provider.send("evm_mine", []); // mine an extra block
                  // await lottery.checkUpkeep([]); // kicks off a transaction because it's not a view function
                  const { upKeepNeeded } = await lottery.callStatic.checkUpkeep(
                      []
                  ); //callstatic simulate calling this transaction and see response
                  assert(!upKeepNeeded);
              });

              it("returns false if raffle is not open", async () => {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  await network.provider.send("evm_increaseTime", [
                      interval + 1
                  ]); // manipulate time of the blockchain
                  await network.provider.send("evm_mine", []);
                  await lottery.performUpkeep("0x"); // 0x or [] == blank object
                  const lotteryState = await lottery.getLotteryState();
                  const { upKeepNeeded } = await lottery.callStatic.checkUpkeep(
                      []
                  );
                  assert.equal(lotteryState.toString(), "1");
                  assert.equal(upKeepNeeded, false);
              });

              it("returns false if enough time hasn't passed", async () => {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  await network.provider.send("evm_increaseTime", [
                      interval - 1
                  ]);
                  await network.provider.request({
                      method: "evm_mine",
                      params: []
                  });
                  const { upKeepNeeded } = await lottery.callStatic.checkUpkeep(
                      []
                  );
                  assert(!upKeepNeeded);
              });
              it("returns true if enough time has passed, has players, eth, and is open", async () => {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  await network.provider.send("evm_increaseTime", [
                      interval + 1
                  ]);
                  await network.provider.request({
                      method: "evm_mine",
                      params: []
                  });
                  const { upKeepNeeded } = await lottery.callStatic.checkUpkeep(
                      []
                  );
                  assert(upKeepNeeded);
              });
          });

          describe("Check performUpkeep", function() {
              it("can only run if checkupkeep is true", async function() {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  await network.provider.send("evm_increaseTime", [
                      interval + 1
                  ]);
                  await network.provider.send("evm_mine", []);
                  const tx = await lottery.performUpkeep("0x");
                  assert(tx); // this assert only work if tx pass through basically.
              });

              it("revert if checkupkeep is false", async function() {
                  await expect(
                      lottery.performUpkeep([])
                  ).to.be.revertedWithCustomError(
                      lottery,
                      "Lottery__upKeepNotNeeded"
                  );
              });

              it("updates the lottery state, emits an event and calls the VRF coordinator", async function() {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  await network.provider.send("evm_increaseTime", [
                      interval + 1
                  ]);
                  await network.provider.send("evm_mine", []);

                  const txResponse = await lottery.performUpkeep("0x");
                  const txReceipt = await txResponse.wait(1);
                  //@ts-ignore
                  const requestId = txReceipt.events[1].args.requestId;
                  // why [1] ?
                  // go to contract/test/VRFCoordinatorV2Mock, in the contract
                  /*    emit RandomWordsRequested(
                _keyHash,
                requestId, -> that's [1]!
                preSeed,
                _subId,
                _minimumRequestConfirmations,
                _callbackGasLimit,
                _numWords,
                msg.sender
              ); */
                  // it's actually an event emitted before our own event
                  const lotteryState = await lottery.getLotteryState();
                  assert(requestId.toNumber() > 0);
                  assert(lotteryState === 1);
              });
          });

          describe("fullfillRandomwords", function() {
              this.beforeEach(async function() {
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  await network.provider.send("evm_increaseTime", [
                      interval + 1
                  ]);
                  await network.provider.send("evm_mine", []);
              });

              it("can only be called after performupkeep", async function() {
                  await expect(
                      vrfCoordinatorV2Mock.fulfillRandomWords(
                          0,
                          lottery.address
                      )
                  ).to.be.revertedWith("nonexistent request");
                  await expect(
                      vrfCoordinatorV2Mock.fulfillRandomWords(
                          1,
                          lottery.address
                      )
                  ).to.be.revertedWith("nonexistent request");
              });

              it("picks a winner, resets the lottery and sends money", async function() {
                  const additionnalEntrances = 3;
                  const startingIndex = 2;
                  for (
                      let i = startingIndex;
                      i < startingIndex + additionnalEntrances;
                      i++
                  ) {
                      lottery = lotteryContract.connect(accounts[i]);
                      await lottery.enterLottery({ value: lotteryEntranceFee });
                  }
                  const startingTimeStamp = await lottery.getLatestTimestamp();

                  // perform upkeep ( mock being chainlink keepers)
                  // fulfilrandomWords (mock being the chainlink VRF)
                  // we have to wait for fulfilRandomwords to be called

                  await new Promise<void>(async (resolve, reject) => {
                      lottery.once("WinnerPicked", async () => {
                          console.log("winnerPicker event fired!");
                          try {
                              console.log("found the event");
                              const recentWinner = await lottery.getRecentWinner();
                              const lotteryState = await lottery.getLotteryState();
                              const winnerBalance = await accounts[2].getBalance();
                              const endingTimeStamp = await lottery.getLatestTimestamp();
                              assert.equal(
                                  recentWinner.toString(),
                                  accounts[2].address
                              );
                              assert.equal(lotteryState, 0);
                              assert.equal(
                                  winnerBalance.toString(),
                                  startingBalance
                                      .add(
                                          lotteryEntranceFee
                                              .mul(additionnalEntrances)
                                              .add(lotteryEntranceFee)
                                      )
                                      .toString()
                              );
                              assert(endingTimeStamp > startingTimeStamp);
                              resolve();
                          } catch (error) {
                              reject(error);
                          }
                      });
                      const tx = await lottery.performUpkeep([]);
                      const txReceipt = await tx.wait(1);
                      const startingBalance = await accounts[2].getBalance();
                      await vrfCoordinatorV2Mock.fulfillRandomWords(
                          txReceipt!.events![1].args!.requestId,
                          lottery.address
                      );
                      const endingBalance = await accounts[2].getBalance();
                      assert(endingBalance > startingBalance)
                  });
              });
          });

          describe("Check getnumWords", () => {
              it("should return the correct value", async function() {
                  const numWords = await lottery.getNumWords();
                  assert.equal(numWords.toString(), "1");
              });
          });
          describe("Check request confirmations", () => {
              it("should return the correct request confirmations", async () => {
                  const requestConfirmation = await lottery.getRequestConfirmations();
                  assert.equal(requestConfirmation.toString(), "3");
              });
          });
          describe("Check the numbers of player", () => {
              it("should return the correct numbers of players", async function() {
                  const initialNumberOfPlayers = await lottery.getNumberOfPlayers();
                  assert.equal(initialNumberOfPlayers.toString(), "0");
                  await lottery.enterLottery({ value: lotteryEntranceFee });
                  const updatedNumberOfPlayers = await lottery.getNumberOfPlayers();
                  assert.equal(updatedNumberOfPlayers.toString(), "1");
              });
          });
      });
