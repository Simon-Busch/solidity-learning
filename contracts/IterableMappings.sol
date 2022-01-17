// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract IterableMapping {
  mapping(address => uint) public balances;
  // can't get the size of mapping 
  // can't iterate to get all values 
  // unless we keep track of all the keys of the mapping 
  
  // check if the key is inserted 
  mapping(address => bool) public inserted;
  address[] public keys;
  
  function setBalance(address _key, uint _bal) external {
    balances[_key] = _bal;
    
    if (!inserted[_key]) {
      inserted[_key] = true;
      keys.push(_key);
    }
  }
  
  function getSize() external view returns (uint) {
    return keys.length;
  }
  
  function first() external view returns (uint) {
    return balances[keys[0]];
  }
  
  function last() external view returns (uint) {
    return balances[keys[keys.length - 1]];
  }
  
  function get(uint _i) external view returns (uint) {
    return balances[keys[_i]];
  }
}