//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
//2 ways to call a parent constructor
// Order of initialization

contract S {
  string public name;
  constructor(string memory _name) {
    name = _name;
  }
}

contract T {
  string public text;
  constructor(string memory _text) {
    text = _text;
  }
}


// #1
//parent constructors can be directly initialized like this if we know the parameters
contract U is S("Simon"),T("Test") {

}

// #2
contract V is S,T {
  constructor(string memory _name, string memory _text) S(_name) T(_text){

  }
}

// #3
contract W is S("Simon"),T {
  constructor(string memory _text) T(_text){

  }
}

// order of initalization 
// S
// T
// V0
contract V0 is S,T {
  // order is the same as the order we call them S(_name) T(_text)
  constructor(string memory _name, string memory _text) S(_name) T(_text){ }
}

// order of initalization 
// S
// T
// V1
contract V1 is S,T {
  // order is the same as the order we call them S(_name) T(_text)
  constructor(string memory _name, string memory _text)  T(_text) S(_name){ }
}

// order of initalization 
// S
// T
// V3
contract V3 is T,S {
  // order is the same as the order we call them S(_name) T(_text)
  constructor(string memory _name, string memory _text)  S(_name)  T(_text) { }
}

