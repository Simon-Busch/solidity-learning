// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
// There are 3 types of variables in Solidity

// - **local**
//     - declared inside a function
//     - not stored on the blockchain
// - **state**
//     - declared outside a function
//     - stored on the blockchain
// - **global** (provides information about the blockchain)

contract Variables {
  // State variables are stored on the blockchain.
  string public text = "Hello";
  uint public num = 123;
  // uint default is uint256 under the hood

  function doSomething() public view {
    // Local variables are not saved to the blockchain.
    uint i = 456;

    // Here are some global variables
    uint timestamp = block.timestamp; // Current block timestamp
    address sender = msg.sender; // address of the caller
  }

  function globalVars() external view returns (address, uint, uint) {
    address sender = msg.sender; /*stores the address that calls the function*/
    uint timestamp = block.timestamp; /*store the unix timestamp of when the function was called*/
    uint blockNum =  block.number; /*stores the current blocknumber*/
    return (sender, timestamp, blockNum);
  }
}
