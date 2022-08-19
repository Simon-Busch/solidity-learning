// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleStorage.sol";

contract StorageFactory {
    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }

    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public {
        // to interract with the contract you need:
        // address
        // ABI - Application Binary Interface
        SimpleStorage simpleStorage = SimpleStorage(simpleStorageArray[_simpleStorageIndex]);
        // !! can do this as well : SimpleStorage simpleStorage = simpleStorageArray[_simpleStorageIndex]
        // we declare a new variable simpleStorage of type SimpleStorage
        // we want to retrieve the matching address
        // We know the index of the contract we are looking for in our array
        // We are looking for a type SimpleStorage in our simpleStorageArray at the given _simpleStorageIndex
        simpleStorage.store(_simpleStorageNumber);

        // simplified version:
        // simpleStorageArray[_simpleStorageIndex].store(_simpleStorageNumber);
    }

    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) {
        // SimpleStorage simpleStorage = SimpleStorage(simpleStorageArray[_simpleStorageIndex]);
        // return simpleStorage.retrieve();
        // simplified version:
        return simpleStorageArray[_simpleStorageIndex].retrieve();
    }
}
