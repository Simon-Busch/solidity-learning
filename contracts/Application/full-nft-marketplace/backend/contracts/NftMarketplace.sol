// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error NftMarketplace__PriceMustBeAboveZero();
error NftMarketplace__NotApprovedForMarketplace();
error NftMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketplace__NotOwner();
error NftMarketplace__NotListed(address nftAddress, uint256 tokenId);
error NftMarketplace__PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);

contract NftMarketplace is ReentrancyGuard {
    /////////////////////
    // Variables //
    /////////////////////

    struct Listing {
        uint256 price;
        address seller;
    }
    // NFT Contract address -> NFT TOKEN ID -> Listing
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    // seller address -> Amount earned
    mapping(address => uint256) private s_proceeds;

    // Events
    event ItemList(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemBought (
      address indexed buyer,
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

    modifier isListed (address nftAddress, uint256 tokenId) {
      Listing memory listing = s_listings[nftAddress][tokenId];
      if (listing.price <=0) {
        revert NftMarketplace__NotListed(nftAddress, tokenId);
      }
      _;
    }

    /////////////////////
    // MAIN FUNCTIONS //
    /////////////////////
    /*
    * @notice Method for listing your NFT on the market place
    *@param _nftAddres: address of the NFT
    *@param _tokenId: the token ID of the NFT
    *@param _price: sale price of the listed NFT
    *@dev technically we could have the contract be the escrow for the NFTs
    * but this way people can still hold their when listed.
    */

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

    function buyItem(address _nftAddress, uint256 _tokenId) external payable isListed(_nftAddress, _tokenId) nonReentrant {
        Listing memory listedItem = s_listings[_nftAddress][_tokenId];
        if (msg.value < listedItem.price) {
          revert NftMarketplace__PriceNotMet(_nftAddress, _tokenId, listedItem.price);
        }
        // we don't just send the seller the money
        // https://fravoll.github.io/solidity-patterns/pull_over_push.html
        // Shift the risk
        // Sending the money to the user ❌
        // Have them withdraw the money ✅
        s_proceeds[listedItem.seller] = s_proceeds[listedItem.seller] + msg.value;
        delete (s_listings[_nftAddress][_tokenId]);
        IERC721(_nftAddress).safeTransferFrom(listedItem.seller, msg.sender, _tokenId);
        // check to make sure the NFT was transfered
        emit ItemBought(msg.sender, _nftAddress, _tokenId, listedItem.price);
    }
}
