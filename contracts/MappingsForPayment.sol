// SPD-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Mapping {
    
  struct Payment {
    uint amount;
    uint timestamp;
  }
  
  struct Balance {
    uint totalBalance;
    uint numPayments;
    mapping(uint => Payment) payments;
  }
  
  mapping(address => Balance) public balanceReceived;
  
  function getBalance() public view returns (uint) {
    return address(this).balance;
  }
  
  function sendMoney() public payable {
    balanceReceived[msg.sender].totalBalance += msg.value;
    Payment memory payment = Payment(msg.value, block.timestamp);
    balanceReceived[msg.sender].payments[balanceReceived[msg.sender].numPayments] = payment;
    balanceReceived[msg.sender].numPayments++ ;
  }
  
  function withdrawMoney(address payable _to, uint _amount) public {
    require(balanceReceived[msg.sender].totalBalance >= _amount, "not enough funds");
    balanceReceived[msg.sender].totalBalance -= _amount;
    (bool success, ) = _to.call{value: _amount}("");
    require(success, "withdraw failed");
  }
  
  //  you can only withdraw what you've sent already
  function withdrawAllMoney (address payable _to) public {
    uint balanceToSend = balanceReceived[msg.sender].totalBalance;
    balanceReceived[msg.sender].totalBalance = 0;
    (bool success, ) = _to.call{value: balanceToSend}("");
    require(success, "withdraw all money failed");
  }
}