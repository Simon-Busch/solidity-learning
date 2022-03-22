// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
// Mapping  similar to hash in Ruby
// key - value
// How to declare a mapping (simple and nested) 
// set, get, delete 



// {"alice", "bob", "simon"} 
// {"alice": true, "bob":true, "simon":true} 

contract Mapping {
  //simple mapping
  mapping(address => uint) public balances; // mapping to initialize, param = (KEY  type => VALUE type )
  //nested mapping 
  mapping(address => mapping(address => bool)) public isFriend;
  
  function examples() external {
    //create the mapping
    balances[msg.sender] = 123;
    // obtain the value of the specified key 
    uint bal = balances[msg.sender];
    //get value of key that doesn't exist yet
    uint bal2 = balances[address(1)]; // 0 as not defined yet, default uint value
    
    
    // update the value 
    balances[msg.sender] = 456;
    
    //delete 
    delete balances[msg.sender]; // value stored for the key will be reseted to default value 
    
    isFriend[msg.sender][address(this)] = true;
  }
}