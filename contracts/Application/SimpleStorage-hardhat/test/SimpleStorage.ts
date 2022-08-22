import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { assert, expect } from "chai";
import { ethers } from "hardhat";
import { SimpleStorage } from "../typechain-types";


describe("SimpleStorage contract", function () {
  let SimpleStorageFactory;
  let simpleStorage: SimpleStorage;
  this.beforeEach(async function () {
    SimpleStorageFactory = await ethers.getContractFactory("SimpleStorage");
    simpleStorage = await SimpleStorageFactory.deploy();
  });

  it("Should start with a favorite number of 0", async function () {
    const currentValue = await simpleStorage.retrieve();
    const expectedValue = "0";
    // expect()
    // assert.equal(currentValue.toString(), expectedValue);
    expect(currentValue.toString()).to.equal(expectedValue);
  });

  // NOTE ON TESTS
  // it.only('Should update when we call store', async function () {
  // if add .only will only run THIS test

  // can also use this command : yarn hardhat test --grep store
  // will run the tests with store in the description
  it("Should update when we call store", async function () {
    const expectedValue = "800";
    const transactionResponse = await simpleStorage.store(expectedValue);
    await transactionResponse.wait(1);
    const currentValue = await simpleStorage.retrieve();
    assert.equal(currentValue.toString(), expectedValue);
  });
});
