// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract TestMultiCall {
  function func1() external view returns (uint, uint) {
    return(1, block.timestamp);
  }

  function func2() external view returns (uint, uint) {
    return (2, block.timestamp);
  }

  function getData1() external pure returns (bytes memory) {
    // == abi.encodeWithSignature("func1()")
    return abi.encodeWithSelector(this.func1.selector);
  }

  function getData2() external pure returns (bytes memory) {
    // == abi.encodeWithSignature("func2()")
    return abi.encodeWithSelector(this.func2.selector);
  }
}

contract MultiCall {
  // pass twice the contract address of TestMultiCall
  // ex : ["0xDA0bab807633f07f013f94DD0E6A4F96F8742B53","0xDA0bab807633f07f013f94DD0E6A4F96F8742B53"]
  // pass an array of the get of getData1 and getData2
  // ex:["0x74135154","0xb1ade4db"]
  function multiCall(address[] calldata contractToBeCalled, bytes[] calldata data) external view returns (bytes[] memory) {
    require(contractToBeCalled.length == data.length, "contractToBeCalled != data length");
    bytes[] memory results = new bytes[](data.length);

    for(uint i; i < contractToBeCalled.length ; i ++) {
      // here it's a view function so we use staticCall instead of call
      // if we would want to send transaction, we would need call instead and remove view
      (bool success, bytes memory result) = contractToBeCalled[i].staticcall(data[i]);
      require(success, "call failed");
      results[i] = result;
    }

    return results;
  }

  // example of response:

  //0x0000000000000000000000000000000000000000000000000000000000000001 --> 1 is from func1
  //00000000000000000000000000000000000000000000000000000000623c2be7, --> time stamp func 1
  // 0x0000000000000000000000000000000000000000000000000000000000000002 --> 2 is from func 2
  // 00000000000000000000000000000000000000000000000000000000623c2be7 --> time stamp func 2
  // NB : time stamps are the same so we can aggregate querries into a single function call
}
