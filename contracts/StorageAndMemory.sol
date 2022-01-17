// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract DataLocations {
  uint[] public arr;
  mapping(uint => address) map;
  struct MyStruct {
    uint foo;
  }
  mapping(uint => MyStruct) myStructs;

  function f() public {
    // call _f with state variables
    _f(arr, map, myStructs[1]);

    // get a struct from a mapping
    MyStruct storage myStruct = myStructs[1];
  //1  = size,memory array are FIXED size
    // create a struct in memory
    MyStruct memory myMemStruct = MyStruct(0);
  //after the function runs, the change will NOT  be saved
  }

  function _f(
    uint[] storage _arr,
    mapping(uint => address) storage _map,
    MyStruct storage _myStruct
  ) internal {
    // do something with storage variables
  }

  // You can return memory variables
  function g(uint[] memory _arr) public returns (uint[] memory) {
    // do something with memory array
  }
  // we can't modify the data of type calldata // save gas
  
  function h(uint[] calldata _arr) external {
    // do something with calldata array
  }
}

contract DataLocation2 {
  struct MyStruct {
    uint foo;
    string text;
  }
  
  mapping(address => MyStruct) public myStructs;
  
  function examples(uint[] calldata y, string memory s) external returns (uint[] memory) {
    myStructs[msg.sender] = MyStruct({foo: 123, text: 'bar'});
    
    MyStruct storage myStruct = myStructs[msg.sender];
    myStruct.text = 'foo';
    
    
    MyStruct memory readOnly = myStructs[msg.sender];
    readOnly.foo = 456;
    //after the function runs, the change will NOT  be saved
    
    uint[] memory memArr = new uint[](3); // 3 = size,memory array are FIXED size
    memArr[0] = 234;
    
    _internal(y);
    return memArr;
  }
  
  // we can't modify the data of type calldata // save gas
  function _internal(uint[] calldata y ) private {
    uint x = y[0];
  }
}