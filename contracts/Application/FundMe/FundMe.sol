// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";
// at the time of writing, goerli network to be selected

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18
    //using constant for var that are set only 1 time make it more gas efficient
    // initial deploy 831,183
    // using constant 811,025
    address public immutable i_owner; // convention to name immutable var like this

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "you are not the owner");
        // string consume more gas. Custom error use less
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        // 1.How to send ETH to this contract ?
        // require(getConversionRate(msg.value) >= minimumUsd, "Didn't send enough ETH");
        // 1eth = 1e18 = 1 * 10 ** 18 == 1000000000000000000
        // could be msg.value >= 1e18

        // msg.value.getConversionRate() === getConversionRate(msg.value)
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() payable public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length ; funderIndex ++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // send

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "failed to withdraw");
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    //important to handle the case if someone trigger a function that doesn't exist or just send eth to the contract
    // otherwise we get eth in the balance but no record of funder
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
