// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Show gas difference
contract ExampleRevert {
    error ExampleRevert__Error();
    function revertWithError() public pure { // 142 gas
        if (false) {
            revert ExampleRevert__Error();
        }
    }

    function revertWithRequire() public pure { // 161 gas
        require(true, "ExampleRevert__Error");
    }
}
