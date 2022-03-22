// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
//call another contract without having its code

// contract Counter {
//   uint public count;
//   function inc() external {
//     count +=1;
//   }

//   function dev() external {
//     count -=1;
//   }
// }

// If we don't have the code of Counter contract but it's deploy somewhere else

interface ICounter {
  function count() external view returns (uint);
  function inc() external;
}

contract CallInterface {
  uint public count;
  function examples (address _counter) external {
    ICounter(_counter).inc();
    count = ICounter(_counter).count();
  }
}