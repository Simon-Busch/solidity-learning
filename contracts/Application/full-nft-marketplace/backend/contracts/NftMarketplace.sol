// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// 1. `listItem`: list NFTs on marketplace
// 2. `buyItem`: buy the NFTs
// 3. `cancelItem`: Cancel a listing
// 4. `updateListing`: Update price
// 5. `withdrawProceeds`: Withdraw payment for my bought NFTs

error NftMarketplace__PriceMustBeAboveZero();

contract NftMarketplace {
    /////////////////////
    // MAIN FUNCTIONS //
    /////////////////////

    function listItem(
        address _nftAddress,
        uint256 _tokenId,
        uint256,
        _price
    ) external {
      if(_price <= 0) {
        revert NftMarketplace__PriceMustBeAboveZero();
      }
      //1. Send the NFT to the contract. Transfer -> Contract "hold" the NFT
      //2. Owners can still hold their NFT and give marketplace approval to sell the NFT for them
      //3. 
    }
}
