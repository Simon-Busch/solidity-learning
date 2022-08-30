import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { network, ethers, getNamedAccounts } from "hardhat";
import { developmentChains } from "../../helper-hardhat-config";
import { Lottery } from "../../typechain-types/contracts/Lottery";

developmentChains.includes(network.name)
    ? describe.skip
    : describe("Raffle Staging Tests", function() {
          let lottery: Lottery;
          let lotteryEntranceFee: BigNumber;
          let deployer: string;
          beforeEach(async function() {
              deployer = (await getNamedAccounts()).deployer;
              lottery = await ethers.getContract("Lottery", deployer);
              lotteryEntranceFee = await lottery.getEntranceFee();
          });

          describe("fulfillRandomWords", function() {
              it("works with live Chainlink Keepers and Chainlink VRF, we get a random winner", async function() {
                  // enter the raffle
                  console.log("Setting up test...");
                  const startingTimeStamp = await lottery.getLatestTimestamp();
                  const accounts = await ethers.getSigners();

                  console.log("Setting up Listener...");
                  await new Promise<void>(async (resolve, reject) => {
                      // setup listener before we enter the lottery
                      // Just in case the blockchain moves REALLY fast
                      lottery.once("WinnerPicked", async () => {
                          console.log("WinnerPicked event fired!");
                          try {
                              // add our asserts here
                              const recentWinner = await lottery.getRecentWinner();
                              const lotteryState = await lottery.getLotteryState();
                              const winnerEndingBalance = await accounts[0].getBalance();
                              const endingTimeStamp = await lottery.getLatestTimestamp();

                              await expect(lottery.getPlayer(0)).to.be.reverted;
                              assert.equal(
                                  recentWinner.toString(),
                                  accounts[0].address
                              );
                              assert.equal(lotteryState, 0);
                              assert.equal(
                                  winnerEndingBalance.toString(),
                                  winnerStartingBalance
                                      .add(lotteryEntranceFee)
                                      .toString()
                              );
                              assert(endingTimeStamp > startingTimeStamp);
                              resolve();
                          } catch (error) {
                              console.log(error);
                              reject(error);
                          }
                      });
                      // Then entering the raffle
                      console.log("Entering Raffle...");
                      const tx = await lottery.enterLottery({
                          value: lotteryEntranceFee
                      });
                      await tx.wait(1);
                      console.log("Ok, time to wait...");
                      const winnerStartingBalance = await accounts[0].getBalance();
                      // and this code WONT complete until our listener has finished listening!
                  });
              });
          });
      });
