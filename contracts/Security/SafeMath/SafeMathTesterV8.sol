// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeMathTester{
    uint8 public bigNumber = 255; // checked

    function add() public {
        bigNumber = bigNumber + 1; // will fail && revert
      // unchecked {bigNumber = bigNumber + 1;}
      // will overflow
      // why would I use unchecked ?
      // makes the code more gas efficient but to use with caution
    }
}
