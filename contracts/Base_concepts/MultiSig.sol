// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    address[] public owners;
    uint256 public required;

    struct Transaction {
        address destination;
        uint256 valueOfTransaction;
        bool executed;
        bytes data;
    }

    modifier onlyOwners {
        bool isOwner = false;
        uint ownersLength = owners.length;
        for (uint i = 0; i < ownersLength ; i ++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
            }
        }
        require(isOwner, "Not owner");
        _;
    }

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;

    constructor(address[] memory _owners, uint256 amountOfConfirmation) {
        require(amountOfConfirmation > 0, "required confirmation must be greater than 0");
        require(amountOfConfirmation < _owners.length, "can't have more conf. than owners");
        require(_owners.length > 0, "must pass minimum 1 owner");
        owners = _owners;
        required = amountOfConfirmation;
    }

    function transactionCount() public view returns(uint) {
        return transactions.length;
    }

    function addTransaction(address destination, uint256 value, bytes memory _data) internal returns (uint256){
        uint256 id = transactions.length;
        transactions.push(Transaction(destination, value, false, _data));
        return id;
    }

    function confirmTransaction(uint transactionId) public onlyOwners {
        confirmations[transactionId][msg.sender] = true;
        if(isConfirmed(transactionId)) {
            executeTransaction(transactionId);
        }
    }

    function getConfirmationsCount(uint transactionId) public view returns (uint) {
        uint ownerLength = owners.length;
        uint count = 0;
        for (uint i = 0; i < ownerLength ; i ++) {
            if (confirmations[transactionId][owners[i]] == true) {
                ++ count;
            }
        }
        return count;
    }

    function submitTransaction(address destination, uint value, bytes memory _data) external {
        uint newTransaction = addTransaction(destination, value, _data);
        confirmTransaction(newTransaction);
    }

    function isConfirmed(uint transactionId) public view returns(bool) {
        return getConfirmationsCount(transactionId) >= required;
    }

    function executeTransaction(uint transactionId) public {
        require(isConfirmed(transactionId) == true, "transaction not confirmed yet");
        Transaction storage transaction = transactions[transactionId];
        require(transaction.executed == false, "transaction already executed");
        (bool success, ) = transaction.destination.call{value: transaction.valueOfTransaction}(transaction.data);
        require(success);
        transaction.executed = true;
    }

    receive() external payable{}
}
