// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

// /!\ does not work as library
abstract contract StringHelper {
    function areStringsEquals(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function isEmptyString(string memory str1) public pure returns (bool) {
        return areStringsEquals(str1, "");
    }

    // first letter : begin is 1
    function slice(
        uint256 begin,
        uint256 end,
        string memory text
    ) public pure returns (string memory) {
        bytes memory a = new bytes(end - begin + 1);
        for (uint256 i = 0; i <= end - begin; i++) {
            a[i] = bytes(text)[i + begin - 1];
        }
        return string(a);
    }

    function remove0x(string memory text) public pure returns (string memory) {
        bytes memory textInBytes = bytes(text);
        uint256 textInBytesLength = textInBytes.length;
        bytes memory a = new bytes(textInBytesLength - 2);
        for (uint256 i = 2; i < textInBytes.length; i++) {
            a[i - 2] = textInBytes[i];
        }
        return string(a);
    }

    function removeUselessZeros(string memory text) public pure returns (string memory) {
        bool canZeroBeRemoved = true;
        bytes memory textInBytes = bytes(text);
        uint256 textInBytesLength = textInBytes.length;
        bytes memory a = new bytes(textInBytesLength - 2);
        for (uint256 i = 2; i < textInBytes.length; i++) {
            if (canZeroBeRemoved && textInBytes[i] == 0x30) continue;
            a[i - 2] = textInBytes[i];
            canZeroBeRemoved = false;
        }
        return string.concat("0x", string(a));
    }

    function isContain(string memory what, string[] memory where) public pure returns (bool) {
        for (uint256 i = 0; i < where.length; i++) {
            if (areStringsEquals(where[i], what)) return true;
        }

        return false;
    }

    function isContain(string memory what, string memory where) public pure returns (bool) {
        uint256 whatBytesLength = bytes(what).length;
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = 0; i <= whereBytesLength - whatBytesLength; i++) {
            if (areStringsEquals(slice(i + 1, i + whatBytesLength, where), what)) return true;
        }

        return false;
    }

    function getPositionStringContained(
        string memory what,
        string memory where
    ) public pure returns (uint256) {
        uint256 whatBytesLength = bytes(what).length;
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = 0; i <= whereBytesLength - whatBytesLength; i++) {
            if (areStringsEquals(slice(i + 1, i + whatBytesLength, where), what)) return i + 1;
        }

        return 0;
    }

    function findFirstCharPositionAfter(
        string memory char,
        uint256 startPosition,
        string memory where
    ) public pure returns (uint256) {
        require(bytes(char).length == 1 && startPosition != 0);
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = startPosition - 1; i < whereBytesLength - 1; i++) {
            if (areStringsEquals(slice(i + 1, i + 1, where), char)) return i + 1;
        }

        return 0;
    }

    function findFirstCharPositionBefore(
        string memory char,
        uint256 startPosition,
        string memory where
    ) public pure returns (uint256) {
        require(bytes(char).length == 1 && startPosition != 0);

        for (uint256 i = startPosition - 1; i > 0; i--) {
            if (areStringsEquals(slice(i + 1, i + 1, where), char)) return i + 1;
        }

        return 0;
    }

    function hexString8ToBytes4(string memory _string) public pure returns (bytes4) {
        require(bytes(_string).length == 8, "Invalid input");

        uint256 result = hexStringToUint(_string);
        return bytes4(bytes32(result) << (4 * (64 - 8)));
    }

    function hexStringToUint(string memory _string) public pure returns (uint256) {
        bytes memory tempBytes = bytes(_string);
        uint256 result;
        for (uint i = 0; i < tempBytes.length; i++) {
            uint8 temp = uint8(tempBytes[i]);
            if (temp >= 48 && temp <= 57) {
                result += (temp - 48) * 16 ** (tempBytes.length - 1 - i);
            } else if (temp >= 97 && temp <= 102) {
                result += (temp - 97 + 10) * 16 ** (tempBytes.length - 1 - i);
            } else {
                revert("Invalid input");
            }
        }
        return result;
    }
}
