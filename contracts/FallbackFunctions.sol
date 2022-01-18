// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
//fallback is executed when
// - function doesn't exist
// - directly send ETH

// fallback() or receive() ?

// Ether is send to contract 
//            |
//    is msg.data empty ? 
//        /        \
//       yes        no
//       /               \
//  receive() exists?  fallback
//     /        \
//    yes       no 
//      /         \
//   receive()   fallback()

contract FunctionExample {
  mapping(address => uint64) public balanceReceived;
  
  function receiveMoney() public payable {
    assert(balanceReceived[msg.sender] + uint64(msg.value) >= balanceReceived[msg.sender]);
    balanceReceived[msg.sender] += uint64(msg.value);
  }
  
  function withdrawMoney(address payable _to, uint64 _amount) public {
    require(_amount <= balanceReceived[msg.sender], "not enough ether bro");
    assert(balanceReceived[msg.sender] >= balanceReceived[msg.sender] - _amount);
    balanceReceived[msg.sender] -= _amount;
    _to.call{value:_amount}("");
  }
  
  // example of fallback function
  receive () external payable {
    receiveMoney();
  }
}

contract Fallback {
  event Log(string _func, address _sender, uint _value, bytes _data);

  //important to mark the fallback as payable 
  fallback() external payable {
    emit Log("Fallback", msg.sender, msg.value, msg.data);
  }

  receive() external payable {
    emit Log("Receive", msg.sender, msg.value, "");
  }
}