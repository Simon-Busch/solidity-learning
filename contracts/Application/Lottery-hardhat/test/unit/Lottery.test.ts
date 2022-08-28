import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { network, deployments, ethers } from "hardhat";
import { Lottery } from "../../typechain-types";
import { developmentChains } from "../../helper-hardhat-config";
import { getNamedAccounts } from "hardhat";
import { Contract } from "ethers";
import { networkConfig } from "../../helper-hardhat-config";

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Testing Lottery", async function () {
          let lottery: Contract,
              lotteryContract,
              vrfCoordinatorV2Mock,
              lotteryEntranceFee,
              interval:any,
              accounts,
              player; // , deployer
          const chainId = network.config.chainId!;

          this.beforeEach(async () => {
              accounts = await ethers.getSigners(); // could also do with getNamedAccounts
              //   deployer = accounts[0]
              player = accounts[1];
              await deployments.fixture(["mocks", "lottery"]); // Deploys modules with the tags "mocks" and "lottery"
              vrfCoordinatorV2Mock = await ethers.getContract(
                  "VRFCoordinatorV2Mock"
              ); // Returns a new connection to the VRFCoordinatorV2Mock contract
              lotteryContract = await ethers.getContract("Lottery"); // Returns a new connection to the lottery contract
              lottery = lotteryContract.connect(player); // Returns a new instance of the lottery contract connected to player
              lotteryEntranceFee = await lottery.getEntranceFee();
              interval = await lottery.getInterval();
          });

          describe("constructor", async function () {
              it("Initialize the lottery correctly", async function () {
                  const lotteryState = (
                      await lottery.getLotteryState()
                  ).toString();
                  assert.equal(lotteryState.toString(), 0);
                  assert.equal(
                      interval.toString(),
                      networkConfig[chainId][
                          "keepersUpdateInterval"
                      ]
                  );
              });
          });
      });
