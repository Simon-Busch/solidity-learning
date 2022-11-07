// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MostSignificantBit {
    function findMostSignificantBit(uint x) external pure returns (uint8 r) {
        // most significat is the left first 1;

        // x > = 0x100000000000000000000000000000000
        if (x >= 2 ** 128) {
            x >>=128; // shift and assign the value
            r += 128;
        }
        // x >= 0x10000000000000000
        if (x >= 2 ** 64) {
            x >>=64;
            r += 64;
        }
        // x >= 0x100000000
        if (x >= 2 ** 32) {
            x >>=32;
            r += 32;
        }
        // x >= 0x10000
        if (x >= 2 ** 16) {
            x >>=16;
            r += 16;
        }
        // x >= 0x100
        if (x >= 2 ** 8) {
            x >>=8;
            r += 8;
        }
        // x >= 0x10
        if (x >= 2 ** 4) {
            x >>=4;
            r += 4;
        }
        // x >= 0x4
        if (x >= 2 ** 2) {
            x >>=2;
            r += 2;
        }
        // x >=  0x2
        if (x >= 2) {
            r += 1;
        }
    }
}
