// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DeployWithCreate2 {
  address public owner;

  constructor(address _owner) {
    owner = _owner;
  }
}

contract Create2Factory {
  event Deploy (address addr);

  // third call -> pass the same random number
  // in the log, deployed address ==  address from second call
  function deploy(uint _salt) external {
    // using Create 2 to deploy the contract
    //  { salt: bytes32(_salt) } 
    // is the only difference
    DeployWithCreate2 _contract = new DeployWithCreate2{
        salt: bytes32(_salt)
    }(msg.sender);
    emit Deploy(address(_contract));
  }

  // second call -> pass the byte code and a random number
  // return an address
  function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {
    bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));

    return address(uint160(uint(hash)));
  }

  //get the byte code of the contract to be deploy
  // first call -> pass our address
  function getByteCode(address _owner) public pure returns (bytes memory) {
    bytes memory bytecode = type(DeployWithCreate2).creationCode;
    return abi.encodePacked(bytecode, abi.encode(_owner));
  }
}
