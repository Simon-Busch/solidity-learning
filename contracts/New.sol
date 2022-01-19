// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Account {
  address public bank;
  address public owner;

  constructor(address _owner) payable {
    bank = msg.sender;
    owner = _owner;
  }
}

//good practice -> Contract that create new contract XXXFactory
contract AccountFactory {
  Account[] public accounts;

  function createAccount(address _owner) external payable {
    // value in Wei
    Account account = new Account{value: 111}(_owner);
    accounts.push(account);
  }
}