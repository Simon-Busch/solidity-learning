// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


contract Structs {
  struct Car {
      string model;
      uint year;
      address owner;
  }
  
  Car public car;
  Car[]public cars;
  mapping(address => Car[]) public carsByOwner;
  
  function examples() external {
    //3 ways to initialize a struct 
    //1. memory means that this car variable will only exist while the function is called
    Car memory  toyota = Car("Toyota", 1990, msg.sender);
    
    //2. pass key value pair
    Car memory lambo = Car({
      model: "Lamborghini",
      year: 1980,
      owner: msg.sender
    });
    // OR 
    //2 bis. if we initialize this way, we don't need to respect the order

    Car memory lambo2 = Car({
      year: 2020,
      model: "Lamborghini",
      owner: msg.sender
    });
    
    //3. 
    Car memory tesla;
    tesla.model = "Tesla";
    tesla.year = 2010;
    tesla.owner = msg.sender;
    
    cars.push(toyota);
    cars.push(lambo);
    cars.push(lambo2);
    cars.push(tesla);
    
    // it's not mandatory to initialize our struct in memory
    
    cars.push(Car("Ferrari", 2020, msg.sender));
    
    
    //access the data
    Car storage _car = cars[0];
    _car.model;
    _car.year;
    _car.owner;
    
    //modify the data 
    // => change to storage
    _car.year = 1999;
    delete _car.owner; //reset to address 0 
    
    delete cars[1]; // {"", 0, 0x... }
  }
}