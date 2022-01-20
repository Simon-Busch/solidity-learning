//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract AccessControl {
  event GrantRole(bytes32 indexed role, address indexed account);
  event RevokeRole(bytes32 indexed role, address indexed account);
  //role => account => bool
  // why role is bytes32 and not string ? because we want to hash it
  mapping(bytes32 => mapping(address => bool)) public roles;

  //private will save some gas
  // 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42  -> input to pass as role !
  bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
  // 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96 -> input to pass as role !
  bytes32 private constant USER = keccak256(abi.encodePacked("USER"));

  modifier onlyRole(bytes32 _role) {
    require(roles[_role][msg.sender], 'not authorized');
    _;
  }

  constructor() {
    // give the admin role to the deployer of the contract
    _grantRole(ADMIN,msg.sender);
  }

  function _grantRole(bytes32 _role, address _account) internal {
    roles[_role][_account] = true;
    emit GrantRole(_role, _account);
  }

  function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
    _grantRole(_role, _account);
  }

  function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
    roles[_role][_account] = false;
    emit RevokeRole(_role, _account);
  }
}