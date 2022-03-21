// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiSigWallet {
  //eth deposit to the wallet
  event Deposit(address indexed sender, uint amount);
  // transaction is submited
  event Submit(uint indexed txId);
  // transaction approved
  event Approve(address indexed owner, uint indexed txId);
  // transaction revoked
  event Revoke(address indexed owner, uint indexed txId);
  // if enough approval transaction can execute
  event Execute(uint indexed txId);

  struct Transaction {
    address to;
    uint value;
    bytes data; // data to be sent to the TO address
    bool executed;
  }

  //only owners can use the contract
  address[] public owners;
  mapping(address => bool) public isOwner;
  // number of approval required for a transaction
  uint public required;

  Transaction[] public transactions;
  // number of the transaction ==> address that approved the transaction or not
  mapping(uint => mapping(address => bool)) public approved;

  modifier onlyOwner() {
    require(isOwner[msg.sender], "not owner");
    _;
  }

  modifier txExists (uint _txId) {
    require(_txId < transactions.length, "tx does not exist");
    _;
  }

  modifier notApproved(uint _txId) {
    require(!approved[_txId][msg.sender], "tx already approved");
    _;
  }

  modifier notExecuted(uint _txId) {
    require(!transactions[_txId].executed, "tx already executed");
  }

  //address[] is the array of owner of the wallet 
  constructor(address[] memory _owners, uint _required) {
    require(_owners.length > 0, "owners required");
    require(_required > 0 && _required <= _owners.length, "invalid required number of owners");

    for(uint i; i < _owners.length; i++) {
      address owner = _owners[i];
      require(owner != address(0), "invalid owner");
      require(!isOwner[owner], "owner if not unique");

      isOwner[owner] = true;
      owners.push(owner);
    }

    required = _required;
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value);
  }

  // calldata because function is external and cheaper on gas in this case
  function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
    transactions.push(Transaction({
      to: _to,
      value: _value,
      data: _data,
      executed: false
    }));
    // transaction index == index of the array
    emit Submit(transactions.length -1);
  }

  function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
    approved[_txId][msg.sender] = true;
    emit Approve(msg.sender, _txId);
  }

  // to save some gas we can initialize the count directly => uint count
  function _getApprovalCount(uint _txId) private view returns (uint count) {
    for(uint i; i < owners.length; i++) {
      // check if owners[i] has approved the transaction
      if(approved[_txId][owners[i]]) {
        count += 1;
      }
    }
    // we don't need to return the count, implicit with how it's declared.
  }

  function execute(uint _txId) external txExists(_txId) notExecuted(_txId) {
    require(_getApprovalCount(_txId) >= required, "approval < required ! ");
    // storage because we will be updating this transaction
    Transaction storage transaction = transactions[_txId];

    transaction.executed = true;

    (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);

    require(success, "transaction failed");

    emit Execute(_txId);
  }

  function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
    //make sure that the transaction has already been approved
    require(approved[_txId][msg.sender], "tx not approved");
    approved[_txId][msg.sender] = false;
    emit Revoke(msg.sender, _txId);
  }
}