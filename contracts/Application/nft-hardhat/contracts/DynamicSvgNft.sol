// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import 'base64-sol/base64.sol'; // yarn base64-sol

contract DynamicSvgNft is ERC721 {

  uint256 private s_tokenCounter;
  string private immutable i_lowImageURI;
  string private immutable i_highImageURI;
  string private constant base64EncodedSvgPrefix = " data:image/svg+xml;base64,";

    constructor(string memory lowSvg, string memory highSvg) ERC721("DYNAMIC SVG NFT", "DSN") {
      s_tokenCounter = 0;
    }

    function mintNft() public  {
      _safeMint(msg.sender, s_tokenCounter);
      s_tokenCounter ++;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
      //abi.encodePacked => 
      string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
      return string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));
    }

    // mint
    //store our svg information somewhere
    // some logic "show x image" or "show y image"
}
