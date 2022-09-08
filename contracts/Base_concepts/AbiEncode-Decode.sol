// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/** From FCC*/

contract Encoding {
    function combineString() public pure returns (string memory) {
        return string(abi.encodePacked("Hello", "World"));
        // returns "HelloWorld"
        // basically concatenate strings together
        // returns bytes object but we type it to string
        // Initial byte return: 0x48656c6c6f576f726c64
    }

    // 0.8.12+ string.contact(stringA, stringB); => concatenate strings

    function encodeNumber() public pure returns(bytes memory) {
        bytes memory number = abi.encode(2);
        return number;
        // returns 0x0000000000000000000000000000000000000000000000000000000000000002
        // Means to encode the number to its binary version
    }

    function encodeString() public pure returns (bytes memory) {
        bytes memory someString = abi.encode("Simon");
        return someString;
        // 0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000553696d6f6e000000000000000000000000000000000000000000000000000000
        // a lot of 0 -- it's not packed. abi.encodedPacked will "compress it"
    }

    // https://forum.openzeppelin.com/t/difference-between-abi-encodepacked-string-and-bytes-string/11837
    // This is great if you want to save space, not good for calling functions.
    // You can sort of think of it as a compressor for the massive bytes object above.
    function encodeStringPacked() public pure returns (bytes memory) {
        bytes memory someString = abi.encodePacked("Simon");
        return someString;
        // 0x53696d6f6e
    }

    function encodeStringBytes() public pure returns(bytes memory) {
        bytes memory someString = bytes("Simon");
        return someString;
        // 0x53696d6f6e
    }

    function decodeString() public pure returns (string memory) {
        // encodeString() => The bytes to decode
        // (string) => the expected format
        string memory someString = abi.decode(encodeString(), (string));
        return someString;
    }

    function multiEncode() public pure returns (bytes memory) {
        bytes memory someString = abi.encode("some string", "another string", "yet a new one");
        return someString;
    }

    function multiDecode() public pure returns (string memory, string memory, string memory) {
        (string memory string1, string memory string2, string memory string3) = abi.decode(multiEncode(), (string, string, string));
        return (string1, string2, string3);
         // some string
        // another string
        // yet a new one
    }

    function multiEncodePacked() public pure returns (bytes memory) {
        bytes memory someString = abi.encodePacked("some string", "it's bigger!");
        return someString;
    }

    function multiStringCastPacked() public pure returns (string memory) {
        string memory someString = string(multiEncodePacked());
        return someString; // "some stringit's bigger!"
    }


    // example: Lottery contract: 0x421C7cFcDFcda9061CA965158E9E88a99de7B292
    // https://goerli.etherscan.io/tx/0x0e3b5c893c9535e228ce6a8e81a7680eaa8bd13033ce97589388cd5fa0532555
    // Input Data = 0xc1af5785 sent in the data field

    // Needed to send a transaction:
    // 1. Abi
    // 2. Contract address
    // How do we send transcation that calls functions with just data field populated ?
    // How do we populate data field ?

    // Solidity has some more "low-level" keywords, namely "staticcall" and "call". We've used call in the past, but
    // haven't really explained what was going on. There is also "send"... but basically forget about send.

    // call: How we call functions to change the state of the blockchain.
    // staticcall: This is how (at a low level) we do our "view" or "pure" function calls, and potentially don't change the blockchain state.
    // When you call a function, you are secretly calling "call" behind the scenes, with everything compiled down to the binary stuff
    // for you. Flashback to when we withdrew ETH from our raffle:

    function withdraw(address recentWinner) public {
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        require(success, "Transfer Failed");
    }

    // Remember this?
    // - In our {} we were able to pass specific fields of a transaction, like value.
    // - In our () we were able to pass data in order to call a specific function - but there was no function we wanted to call!
    // We only sent ETH, so we didn't need to call a function!
    // If we want to call a function, or send any data, we'd do it in these parathesis!

}
