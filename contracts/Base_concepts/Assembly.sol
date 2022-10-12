// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
// Reference : https://ethervm.io/
contract Assembly {
    function foo() external {
      uint256 a;
      uint256 b;
      uint256 c;
      uint256 size;
      address addr = msg.sender;
      bytes memory data = new bytes(10);
      bytes32 dataB32;
      /*
      * := -> = in assembly
      * No ;
      * Can declare variable with let
      * declare the actions with op code ( here "add" )
      * mload -> load data from memory slot, pass it the address of the slot
      * mstore -> store something in memory 1st arg destination 2nd arg payload !! must fit in  256 bits
      *   -> Not persistent, only available during function execution
      * sstore -> store
      *   -> persistent after function execution
      * extcodesize -> return the size of the code in a specific ethereum address
      */
      assembly {
          // c := add(1, 2)
          // let a := mload(0x40)
          // mstore(a, 2)
          // sstore(a, 10)
          size := extcodesize(addr)
          // cast bytes to bytes32
          // can only be done with assembly
          dataB32 := mload(add(data, 32)) // why do we add 32 bytes here ?
          // first memory slot is the size of the bytes
          // data start actually at the second slot
      }

      if (size > 0) {
        return true;  // if > 0 this is a smart contract address
      } else {
        return false; // if 0 this is a normal ethereum address
      }
    }
}
