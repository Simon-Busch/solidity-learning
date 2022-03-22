// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Event {
  event Log(string _message, uint _val);
  event IndexedLog(address indexed _sender, uint _val);
  //indexed allow us to look on web3 by the parameter

  // transactional function because we are storing data on the blockchain
  function example() external {
    emit Log('foo', 32);
    emit IndexedLog(msg.sender, 12);
  }

  // up to 3 params can be indexed
  event Message(address indexed _from, address indexed _to, string _message );

  function sendMessage( address _to, string calldata _message) external {
    emit Message(msg.sender, _to, _message);
  }
}