// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract CallTestContract {
  function setX(TestContract _test, uint _x) external {
    // call the "testcontract" deploy at address _test
    _test.setX(_x);
  }

  // anotherway to call the contract
  function getX(address _test) external view returns (uint) {
    // uint x = TestContract(_test).getX();
    // return x;
    return TestContract(_test).getX();
  }

  function setXandSendEther(address _test, uint _x) external payable {
    // call the "testcontract" deploy at address _test
    //value is the amount of ether
    TestContract(_test).setXandReceiveEther{value: msg.value}(_x);
  }
  
  //return multiple values
  function getXandValue(address _test) external view returns (uint, uint) {
    (uint x, uint value) =  TestContract(_test).getXandValue();
    return (x, value);
  }
}

contract TestContract {
  uint public x;
  uint public value = 123;

  function setX(uint _x) external {
    x = _x;
  }

  function getX() external view returns (uint) {
    return x;
  }

  function setXandReceiveEther (uint _x) external payable {
    x = _x;
    value = msg.value;
  }

  function getXandValue () external view returns (uint, uint) {
    return(x, value);
  }
}