// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// selfdestruct
// - delete contract
// - force send Ether to any address

contract Kill {
  constructor() payable {

  }
  function kill() external {
    // params of self destruct is the address where all ether will ber sent
    selfdestruct(payable(msg.sender)); 
  }

  function testCall() external pure returns (uint) {
    return 123;
  }
}

contract Helper {
  function getBalance() external view returns (uint) {
    return address(this).balance;
  }

  function kill(Kill _kill) external {
    _kill.kill(); // call kill on Kill contract
  }
  // means that we should force to receive the remaining ether of Kill in Helper contract even without a fallback function
}