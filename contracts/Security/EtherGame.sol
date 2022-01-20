//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract EtherGame {
  uint public targetAmount = 7 ether;
  uint public balance;
  address public winner;

  function deposit() public payable {
    require(msg.value == 1 ether, "You can only send  1 ETH");

    // avoid attack
    // uint blance = address(this).balance;
    balance += msg.value;
    require(balance <= targetAmount, "Game is over");

    if (balance == targetAmount) {
      winner = msg.sender;
    }
  }

  function claimReward() public {
    require(msg.sender == winner, "You are not the winner");

    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "failed to send Ether");
  }

  function getBalance() public view returns (uint) {
    return address(this).balance;
  }
}

// Conter attack where malicious people could call selfdestruct !

// contract Attack {
//   EtherGame _etherGame;

//   constructor(EtherGame _deployedAddress) {
//     _etherGame = EtherGame(_deployedAddress);
//   }

//   function attack() public payable {
//     // you could break the game by sending ether so that the game balance is >= 7ether
//     address payable addr = payable(address(_etherGame));
//     selfdestruct(addr); 
//   }
// }