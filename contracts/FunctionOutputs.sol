// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// return multiple FunctionOutputs
// named outputs 
// destructuring assignment

contract FunctionOutputs {
  //return multiple outputs
  function returnMany() public pure returns (uint, bool) {
    return (1, true);
  }
  
  //named outputs
  function named() public pure returns (uint x, bool b) {
    return (1, true);
  }
  
  function assigned() public pure returns (uint x, bool b) {
    x = 1;
    b = true;
    //implicit return
  }
  
  function destructuringAssignemnts() public pure {
    (uint x, bool b) = returnMany();
    (,  bool _b) = returnMany(); //here we don't need the first var so we just take the second one
  }
}