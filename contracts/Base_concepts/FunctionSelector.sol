// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract FunctionSelector {
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }
}

// if we deploy this contract, and pass "transfer(address,uint256)" as input, we will get 
// 0xa9059cbb

contract Receiver {
  event Log(bytes data);
  function transfer(address _to, uint _amount) external {
    emit Log(msg.data);
    // 0xa9059cbb  || first 4 bytes -> encodes the function to call => called function Selector
    // 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 // address passed 
    // 000000000000000000000000000000000000000000000000000000000000000b // amount passed
    // the rest of the data is the function param to pass to the function 
  }
}