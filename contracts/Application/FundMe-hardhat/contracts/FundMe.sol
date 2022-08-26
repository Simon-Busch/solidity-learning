// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";
// import "hardhat/console.sol";
// at the time of writing, goerli network to be selected

error FundMe__NotOwner();

// convention : contractName__ERROR

///@title a contract for crowd function
///@author Patrick Collins
///@notice This contract is do demo a sample funding contract
///@dev This implements price feeds as our library
//nb: https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout

contract FundMe {
    // type declaration
    using PriceConverter for uint256;

    //State variables
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner; // convention to name immutable var like this
    address[] private s_funders;
    AggregatorV3Interface private s_priceFeed;

    // Events
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    ///@notice this function funds the contract
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public payable onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "failed to withdraw");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "failed to withdraw");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
