// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

//can't declare state variable in a library
library Math {
  function max(uint _x, uint _y) internal pure returns (uint) {
    return _x >= _y ? _x : _y;
  }
}

contract Test {
  function testMax(uint _x, uint _y) external pure returns (uint) {
    return Math.max(_x, _y);
  }
}

library ArrayLib {
  //view because we are reading from state variable 
  function find(uint[] storage _arr,  uint _x) internal view returns (uint) {
    for (uint i = 0; i < _arr.length ; i++) {
      if (_arr[i] == _x) {
        return i;
      }
    }
    revert("not found");
  }
}

contract TestArray {
  using ArrayLib for uint[];
  // for uint[] data type, attach all functionnalities in ArrayLib
  uint[] public arr = [3,2,1];

  function testFind() external view returns (uint i) {
    return arr.find(2);
  }
}