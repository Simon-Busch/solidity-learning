// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Delegate call will help use to keep the context of the function called ( msg.sender for example )

contract MultiDelegateCall {
  error DelegateCallFailed();

  function multiDelegateCall(bytes[] calldata data) external payable returns (bytes[] memory results) {
    //results need to have exactly the same length as the bytes [] passed
    results = new bytes[](data.length);
    for (uint i; i < data.length; i++) {
      (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
      if (!ok) {
        revert DelegateCallFailed();
      }
      results[i] = res;
    }
  }
}

// why use multi delegatecall ?  
// bob -> multi call contract --- call ---> test (msg.sender = multi call contract)
// if we want the msg.sender to be bob we need multi delegate call
// bob --> testContract --- delegatecall ---> test (msg.sender = bob)

contract TestMultiDelegateCall is MultiDelegateCall {
  event Log(address caller, string func, uint i);

  function func1(uint x, uint y) external {
    emit Log(msg.sender, "func 1", x+y);
  }

  function func2() external returns (uint) {
    emit Log(msg.sender, "func 2", 2);
    return 111;
  }

  mapping(address => uint) public balanceOf;

  //WARNING unsafe code used in combination with multi-delegatecall
  //user can mint multiple times for the price of msg.value
  function mint() external payable {
    balanceOf[msg.sender] += msg.value;
  }
}


contract Helper {
  function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
    return abi.encodeWithSelector(TestMultiDelegateCall.func1.selector, x, y);
  }

  function getFunc2Data() external pure returns (bytes memory) {
    return abi.encodeWithSelector(TestMultiDelegateCall.func2.selector);
  }

  function getMintData() external pure returns (bytes memory) {
    return abi.encodeWithSelector(TestMultiDelegateCall.mint.selector);
  }
}

// deploy TestMultiDelegateCall
// deploy Helper
// trigger both function from helper
// pass the bytes in an array to multiDelegateCall
// ==> same caller for both function 