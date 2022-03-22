// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract HashFunc {
  function hash(string memory _text, uint _num, address _addr) external pure returns (bytes32) {
    return keccak256(abi.encodePacked(_text, _num, _addr));
  }

  // difference between abi.encode && abi.encodePacked 
  // abi.encode -> encodes the data into bytes
  // abi.encodePacked -> encodes the data into bytes AND compresses it

  function encode(string memory _text, string memory _text1) external pure returns (bytes memory) {
    return abi.encode(_text, _text1);
  }

  /* OUTPUT:
    bytes: 0x000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034242420000000000000000000000000000000000000000000000000000000000
  */

  function encodePacked(string memory _text, string memory _text1) external pure returns (bytes memory) {
    return abi.encodePacked(_text, _text1);
  }

  /* OUTPUT:
    bytes:  0x414141424242
  */

  function collission(string memory _text0, string memory _text1) external pure returns (bytes32) {
    return keccak256(abi.encodePacked(_text0, _text1));
  }

  // be careful with hash cohesin 
  // test "AAAA", "BBB"
  // -> bytes: 0x41414141424242
  // test 2: "AAA", "ABBB"
  // bytes: 0x41414141424242
  // AVOID IT BY USING ENCODE instead of ENCODEPACKED
}