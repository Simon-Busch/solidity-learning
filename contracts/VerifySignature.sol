// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// 1) Message to sign
// 2) Hash(message)
// 3)sign(hash(message), private key) | off chain
// 4) ecrecover(hash(message), signature) == signer

contract VerifySignature {
  function verify(string memory _message, bytes memory _signature, address _signer) external pure returns (bool) {
    bytes32 messageHash = getMessageHash(_message);
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

    return recover(ethSignedMessageHash, _signature) == _signer;
  }

  function getMessageHash(string memory _message) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(_message));
  }

  function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_messageHash)); // offchain
  }

  function recover(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = _split(_signature);
    return ecrecover(_ethSignedMessageHash, v,r,s);
  }

  function _split(bytes memory _signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) { 
    //_signature is not the actual signature but is a POINTER to where it's stored in memory
    //bytes length = 32 + 32 + 1 (uint 8 is 1 byte) => 65 bytes
    require(_signature.length == 65, "invalid signature length");
    assembly {
      r:= mload(add(_signature, 32)) // skip the first 32  bytes which are jute the length of the sign, so we need to skip it
      s:= mload(add(_signature, 64)) // skip the next 32 bytes which store the value of r
      v:= byte(0,mload(add(_signature, 96))) // skip the next 32 which store the value of s
    }
    //implicit return
  }
}

/*
  In order to test it:
  1) Deploy the contract on remix
  2) enter a message in getMessageHash
  3) open the console of the browser
    a) ethereum.enable()
    b) create var account = "ADDRESS THAT YOU'LL  BE USING"
    c) create var hash = return of getMessageHash(_message)
    d) sign the transaction : ethereum.request({method: "personal_sign", params: [account, hash]})
    e) sign the message on metamask popup
    f) return a promise with a result == signature
  4) call getEthSignedMessageHash(getMessageHash(_message)) 
  5) call recover with the result of above call && the signature from the from browser console --> returns an address which should be the same as account
  6) call verify with account, the message in string format, and the signature from the browser console ==> should return true if everything is correct
 */