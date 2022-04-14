// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
/*
How to optimize gas in a contract  ?
 */

contract GasSaving {
  // from transaction log we can check transaction cost in gas
  // start - 50992 gas
  // use calldata instead of memory for nums - 49163 gas
  // load state var to memory instead of updating total for each loop - 50781 gas
  // short circuit - 50460 gas
  // loop increments - 50070 gas
  // cache array length - 48209 gas
  // load array elements to memory - 48047 gas

  uint public total;

  // [1, 2, 3, 4, 5, 100]
  function sumIfEvenAndLessThan99(uint[] calldata nums ) external {
    uint _total = total;
    // // for (uint i = 0; i < nums.length ; i+= 1) {
    // for (uint i = 0; i < nums.length ; ++ i) { // ++ i instead of i += 1 saves gas 
    // set up the var at the beginning saves gas
    uint length = nums.length;
    for (uint i = 0; i < length ; ++ i) {
      //bool isEven = nums[i] % 2 == 0;
      //bool isLessThan99 = nums[i] < 99;
      //if (isEven && isLessThan99) { // this causes double computation so more gas
      //if (nums[i] % 2 == 0 && nums[i] < 99) { // with this, if the first condition is false, we exit earlier
      //  //total += nums[i];
      //  _total += nums[i];
      //}
      uint num = nums[i];
      // declaring only once the var saves gas
      if (num % 2 == 0 && num < 99) { // with this, if the first condition is false, we exit earlier
        _total += num;
      }
    }
    total = _total;
  }
}