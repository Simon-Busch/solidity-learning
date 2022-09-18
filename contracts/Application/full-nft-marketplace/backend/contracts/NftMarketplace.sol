// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftMarketplace__PriceMustBeAboveZero();
error NftMarketplace__NotApprovedForMarketplace();
error NftMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketplace__NotOwner();

contract NftMarketplace {
    /////////////////////
    // Variables //
    /////////////////////

    struct Listing {
        uint256 price;
        address seller;
    }
    // NFT Contract address -> NFT TOKEN ID -> Listing
    mapping(address => mapping(uint256 => Listing)) private s_listings;

    // Events
    event ItemList(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    /////////////////////
    // Modifiers //
    /////////////////////
    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert NftMarketplace__AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NftMarketplace__NotOwner();
        }
        _;
    }

    /////////////////////
    // MAIN FUNCTIONS //
    /////////////////////

    function listItem(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _price
    )
        external
        notListed(_nftAddress, _tokenId, msg.sender)
        isOwner(_nftAddress, _tokenId, msg.sender)
    {
        if (_price <= 0) {
            revert NftMarketplace__PriceMustBeAboveZero();
        }
        //1. Send the NFT to the contract. Transfer -> Contract "hold" the NFT
        //2. Owners can still hold their NFT and give marketplace approval to sell the NFT for them
        IERC721 nft = IERC721(_nftAddress);
        if (nft.getApproved(_tokenId) != address(this)) {
            revert NftMarketplace__NotApprovedForMarketplace();
        }
        s_listings[_nftAddress][_tokenId] = Listing(_price, msg.sender);
        emit ItemList(msg.sender, _nftAddress, _tokenId, _price);
    }
}
