// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Enums {
  // exemple if we need more option than bool T | F 
  enum Status {
    None, // 0
    Pending, // 1
    Shipped, // 2
    Completed, // 3
    Rejected, // 4
    Canceled // 5
  }
  
  Status public status; 
  
  struct Order {
    address buyer;
    Status status;
  }
  
  Order[] public orders;
  
  //return the status
  function getStatus() view external returns (Status) {
    return status;
}
  
  // take enum as input 
  function setStatus(Status _status) external {
    status = _status;
  }
  
  // update enum to a specific enum
  function ship() external {
    status = Status.Shipped;
  }
  
  //set the enum to its default value
  function reset() external {
    delete status; // 0 
  }
}