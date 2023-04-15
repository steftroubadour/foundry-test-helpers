// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Bits } from "src/library/Bits.sol";

library Arrays {
    // Equals at each rank
    function areEquals(uint8[] memory x, uint8[] memory y) public pure returns (bool) {
        if (x.length != y.length) return false;
        if (x.length == 0) return true;

        for (uint n = 0; n < x.length; n++) {
            if (x[n] != y[n]) return false;
        }

        return true;
    }

    function areEquals(uint256[] memory x, uint256[] memory y) public pure returns (bool) {
        if (x.length != y.length) return false;
        if (x.length == 0) return true;

        for (uint n = 0; n < x.length; n++) {
            if (x[n] != y[n]) return false;
        }

        return true;
    }

    function toUint8Array(uint256[] memory x) public pure returns (uint8[] memory) {
        uint8[] memory numbers = new uint8[](x.length);

        for (uint n = 0; n < x.length; n++) {
            assert(x[n] < 2 ** 8);
            numbers[n] = uint8(x[n]);
        }

        return numbers;
    }

    /*function fillWithValues(
        uint256[] memory x,
        uint256[] memory values
    ) public pure returns (uint256[] memory) {
        assert(x.length <= values.length);
        for (uint n = 0; n < x.length; n++) {
            x[n] = values[n];
        }

        return x;
    }*/

    function completeWithZeros(
        uint256[] memory x,
        uint256 length
    ) public pure returns (uint256[] memory) {
        uint256[] memory y = new uint256[](length);
        for (uint n = 0; n < x.length; n++) {
            y[n] = x[n];
        }

        return y;
    }

    // till 32 x 8bits = 256 bits
    // 32 values in [0; 255] : uint8[32]
    // to have a good number, x must be in [2 ** 255; 2 ** 256 - 1] = bound(number, 2 ** 255, type(uint256).max);
    function uintToArray(uint256 x, uint256 length) public pure returns (uint256[] memory) {
        uint256[] memory values = new uint256[](length);
        for (uint n = 0; n < length; n++) {
            values[n] = Bits.getNth8Bits(x, n);
        }

        return values;
    }

    function toUint(uint8[] memory x) public pure returns (uint256) {
        assert(x.length <= 32);

        uint256 number;

        for (uint n = 0; n < x.length; n++) {
            number += x[n] * 2 ** (8 * n);
        }

        return number;
    }

    function toString(uint256[] memory x) public pure returns (string memory) {
        string memory s = "[";
        for (uint n = 0; n < x.length; n++) {
            s = string.concat(s, Strings.toString(x[n]), n < x.length - 1 ? ", " : "");
        }

        return string.concat(s, "](", Strings.toString(x.length), ")");
    }

    function toString(uint8[] memory x) public pure returns (string memory) {
        string memory s = "[";
        for (uint n = 0; n < x.length; n++) {
            s = string.concat(s, Strings.toString(x[n]), n < x.length - 1 ? ", " : "");
        }

        return string.concat(s, "](", Strings.toString(x.length), ")");
    }
}
