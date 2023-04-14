// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

library Bits {
    // @param n start at 1
    function getLastNBits(uint256 x, uint256 n) public pure returns (uint256) {
        assert(n > 0);
        // Example, last 3 bits
        // x        = 1101 = 13
        // mask     = 0111 = 7
        // x & mask = 0101 = 5
        uint256 mask = (1 << n) - 1;
        return x & mask;
    }

    function getLast8Bits(uint256 x) public pure returns (uint256) {
        return getLastNBits(x, 8);
    }

    // a number between 2^(8 * n) & 2^(8 * (n+1)) - 1
    function getNth8Bits(uint256 x, uint256 n) public pure returns (uint256) {
        return getLast8Bits(x >> (8 * n));
    }

    // @param from start at 1
    // @param to start at 1
    function getRangeOfBits(uint256 x, uint256 from, uint256 to) public pure returns (uint256) {
        assert(from > 0 && to > 0);
        if (from == 1) return getLastNBits(x, to);

        return getLastNBits(x, to) - getLastNBits(x, from - 1);
    }

    function sliceBits(uint256 x, uint256 from, uint256 to) public pure returns (uint256) {
        return getRangeOfBits(x, from, to) >> (from - 1);
    }

    function toArrayOfBits(uint256 x) public pure returns (uint8[] memory) {
        uint8[] memory a = new uint8[](256);
        for (uint n = 0; n < 256; n++) {
            a[n] = uint8(((1 << n) & x) >> n);
        }

        return a;
    }

    function toNumber(uint8[] memory a) public pure returns (uint256) {
        uint256 number;
        for (uint n = 0; n < a.length; n++) {
            number += a[n] * 2 ** n;
        }

        return number;
    }

    function arrayOfBitsToString(uint8[] memory a) public pure returns (string memory) {
        string memory s;
        for (uint n = 0; n < a.length; n++) {
            // print inverse order
            s = string.concat(
                s,
                Strings.toString(a[a.length - 1 - n]),
                ((a.length - 1 - n) % 8 == 0) && n != a.length - 1 ? "-" : ""
            );
        }

        return s;
    }
}
