// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract KingOfEther {
  address public king;
  uint public throneCost;
  mapping(address => uint) public balances;

  function claimThrone() external payable {
    require(msg.value > throneCost, "You need to send more ETH to become the king");
    
    balances[king] += msg.value;

    throneCost = msg.value;
    king = msg.sender;
  }

  function withdraw() public {
    require(msg.sender != king, "current king cannot withdraw");

    uint amount = balances[msg.sender];
    balances[msg.sender] = 0;

    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "withdraw failed");
  }
}


// avoid with withdraw function and mapping
contract Attack {
  KingOfEther kingOfEther;

  constructor (KingOfEther _deployedAddress) {
    kingOfEther = KingOfEther(_deployedAddress);
  }

  function attack() public payable {
    kingOfEther.claimThrone{value: msg.value};
  }
}