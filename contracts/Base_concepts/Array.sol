// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Array -> dynamic or fixed size
// Initialization 
// Insert ( push ), get, update, delete, pop, length
// Creating array in memory
// Returning array from function 

contract Array {
  uint[] public myArray = [1,2,3]; // dynamic sized array
  uint[3] public myFixedArray = [4,5,6]; // fixed size array, specify the size of the array 
  
  function example() external {
    myArray.push(4); // [1,2,3,4]
    uint x = myArray[0]; // 1
    myArray[2] = 777; // [1,2,777,4]
    delete myArray[1]; // this is how to delete element -> [1,0,777,4] 
    // important, the size of the array doesn't change but value is set to 0
    
    myArray.pop(); // the only way to change size of the array [1,0,777]
    uint length = myArray.length; // 3
    
    //create array in memory -> 5 is the size of the array
    // HAS TO BE OF FIXED SIZE
    uint[] memory a = new uint[](5);
    a[1] = 123;
    
  }
  
  function returnArray() external view returns (uint[] memory) {
    //returning an array from memory is not recommended.
    // the bigger the array, the more gas it consume
    return myArray;
  }
}