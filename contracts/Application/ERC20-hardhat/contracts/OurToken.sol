// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {


  // when is ERC20 we need to pass arguments to the constructor
  constructor(uint256 initialSupply) ERC20("SBU Token", "SBU") {
    _mint(msg.sender, initialSupply); // msg.sender will own all tokens by default
  }


}
