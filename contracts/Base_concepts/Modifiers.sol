// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ModifierExample {
  address owner;

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not allowed");
  _;
  }

  mapping(address => uint) public tokenBalance;
  uint tokenPrice = 1 ether;

  constructor () public {
    owner = msg.sender;
    tokenBalance[owner] = 100;
  }

  function createNewToken() public onlyOwner {
    tokenBalance[owner] ++;
  }

  function burnToken() public onlyOwner {
    tokenBalance[owner] --;
  }

  function purchaseToken() public payable {
    require((tokenBalance[owner] * tokenPrice) / msg.value > 0, "not enough tokens");
    tokenBalance[owner] -= msg.value / tokenPrice;
    tokenBalance[msg.sender] += msg.value / tokenPrice;
  }

  function sendToken(address _to, uint _amount) public {
    require(tokenBalance[msg.sender] >= _amount, "not enough token");
    assert(tokenBalance[_to] + _amount >= tokenBalance[_to]);
    assert(tokenBalance[msg.sender] - _amount <= tokenBalance[msg.sender]);
  }
}