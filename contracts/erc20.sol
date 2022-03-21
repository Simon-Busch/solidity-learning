// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
  function totalSupply() external view returns (uint);

  function balanceOf(address account) external view returns (uint);

  function transfer(address recipient, uint amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint amount);

  event Approval(address indexed owner, address indexed spender, uint amount);
}

contract ERC20 is IERC20 {
  uint public totalSupply;
  mapping(address => uint) public balanceOf;
  mapping(address => mapping(address => uint)) public allowance;
  string public name = "Token";
  string public symbol = "TK";
  uint8 public decimals = 18; // how many 0 are used to represent 1 ERC20 token

  function transfer(address recipient, uint amount) external returns (bool) {
    // as from Solidity 0.8 overflow is not accepted anymore, no need to make a 
    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function approve(address spender, uint amount) external returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
    allowance[sender][msg.sender] -= amount;
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function mint(uint amount) external {
    balanceOf[msg.sender] += amount;
    totalSupply += amount;
    // address(0) for from because token are minted
    emit Transfer(address(0), msg.sender, amount);
  }

  function burn(uint amount) external {
    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
    // address(0) for from because token are minted
    emit Transfer(msg.sender, address(0), amount);
  }
}