// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol"; // yarn base64-sol

contract DynamicSvgNft is ERC721, Ownable {
    uint256 private s_tokenCounter;
    string private s_lowImageURI;
    string private s_highImageURI;
    string private constant base64EncodedSvgPrefix =
        " data:image/svg+xml;base64,";

    AggregatorV3Interface internal immutable i_priceFeed;
    mapping(uint256 => int256) private s_tokenIdToHighValues;
    event CreatedNFT(uint256 indexed tokenId, int256 highValue);

    constructor(
        address priceFeedAddress,
        string memory lowSvg,
        string memory highSvg
    ) ERC721("DYNAMIC SVG NFT", "DSN") {
        s_tokenCounter = 0;
        s_lowImageURI = svgToImageURI(lowSvg);
        s_highImageURI = svgToImageURI(highSvg);
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function mintNft(int256 highValue) public {
        s_tokenIdToHighValues[s_tokenCounter] = highValue;
        emit CreatedNFT(s_tokenCounter, highValue);
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;

    }

    function svgToImageURI(string memory svg)
        public
        pure
        returns (string memory)
    {
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return
            string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));
        // will concatenate strings
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    // generate the metaData
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI Query for nonexistent token");
        string memory imageURI = s_lowImageURI;
        // need to get the lastestRoundData to know the price and adapt imageURI accordingly
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        // we need to know if price is increasing or decreasing  ( AggregatorV3Interface )

        if (price >= s_tokenIdToHighValues[tokenId]) {
            imageURI = s_highImageURI;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getLowSVG() public view returns (string memory) {
        return s_lowImageURI;
    }

    function getHighSVG() public view returns (string memory) {
        return s_highImageURI;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
