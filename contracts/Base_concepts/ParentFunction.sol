//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract A {
  event Log(string _message);

  function foo() public virtual {
    emit Log("A.Log");
  }

  function bar() public virtual {
    emit Log("A.Bar");
  }
}

contract B is A {
  function foo() public virtual override {
    emit Log("B.Log");
    A.foo(); // emit Log("A.Log");
  }

  function bar() public virtual override {
    emit Log("B.Bar");
    super.bar(); // calls the parents function 
    //emit Log("A.Bar");
  }
}


contract C is A {
  function foo() public virtual override {
    emit Log("C.Log");
    A.foo(); // emit Log("A.Log");
  }

  function bar() public virtual override {
    emit Log("C.Bar");
    super.bar(); // calls the parents function 
    //emit Log("A.Bar");
  }
}


contract D is B,C {
  function foo() public virtual override (B,C) {
    B.foo(); // emit Log("B.Log"); &&  emit Log("A.Log");
    // !! calling this way only call the function
  }

  function bar() public virtual override (B,C) {
    // !! using super here call all parents ( triggers B & C)
    super.bar();  
  }
}