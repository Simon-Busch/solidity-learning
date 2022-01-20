// SPD-License-Identifier: MIT
pragma solidity ^0.8.3;
// anyone can send ETH to the contract BUT only owner can withdraw
contract PiggyBank {
  address payable public owner;
  event Deposit(uint amount);
  event Withdraw(uint amount);

  constructor() {
    owner = payable(msg.sender);
  }

  receive() external payable {
    emit Deposit(msg.value);
  }

  function withdraw() external {
    require(msg.sender == owner, "You are not the owner");
    emit Withdraw(address(this).balance);
    selfdestruct(owner);
  }
}