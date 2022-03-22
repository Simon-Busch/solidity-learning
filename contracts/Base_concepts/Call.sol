// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// call can be used to call functions from other contracts

contract TestCall {
  string public message;
  uint public x;

  event Log(string message);

  fallback() external payable {
    emit Log("fallback was called");
  }

  receive() external payable{}

  function foo(string memory _message, uint _x) external payable returns (bool, uint) {
    message = _message;
    x = _x;
    return (true, 999);
  }
}

contract Call {
  bytes public data; 

  function callFoo(address _test) external payable {
    //encodeWithSignature(X,Y|Z|...)
    // X => name of the function we want to call at the _test address ( contract ) 
    // !! uint must be specified -> ex: uint256
    // no space in the function call
    //  Y | Z | ... -> all argumentes passed to X
    (bool success, bytes memory _data) = _test.call{value: 111, gas: 5000}(abi.encodeWithSignature("foo(string,uint256)", "call food", 123));
    require(success, "call failed");
    data = _data;
  }

  function callDoesNotExist(address _test) external {
    (bool success, ) = _test.call(abi.encodeWithSignature("functionWhichDoesNotExist()"));
    require(success, "call failed");
  }
}