// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract SafeMathTester{
    uint8 public bigNumber = 255; // unchecked
    // here, for uint8 the maximum value is 256

    function add() public {
        bigNumber = bigNumber + 1; // overflow
    }

    function substract() public {
        bigNumber = bigNumber - 255;
    }
}
