// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


contract ViewAndPureFunctions {

  uint public num;
  function viewFunc() external view returns (uint) {
    return num;
  }
  /*Here it's view because num is stored on the blockchain*/
  
  function pureFunc() external pure returns (uint) {
    return 1;
  }
  /*Doesn't read any data fromthe blockchain*/
  
  
  function addToNum(uint x) external view returns (uint) {
    return num+x;
  }
  
  function add(uint x, uint y) external pure returns (uint) {
    return y + x;
  }
}