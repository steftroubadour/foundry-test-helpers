// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Test } from "forge-std/Test.sol";
import { RandomHelper } from "./RandomHelper.sol";

abstract contract TestHelper is Test, RandomHelper {
    function _bound2(uint256 x, uint256 min, uint256 max) internal pure virtual returns (uint256) {
        if (x >= min && x <= max) return x;

        uint256 size = max - min + 1;
        uint256 diff;
        uint256 rem;

        if (x > max) {
            diff = x - max;
            rem = diff % size;
            return min + rem;
        }
        // x < min
        diff = min - x;
        rem = diff % size;
        return min + rem;
    }

    /// @param x = bound2(number, 10000, 99999);
    function bound2(uint256 x, uint256 min, uint256 max) public pure virtual returns (uint256) {
        uint256 n = _bound2(x, min, max);

        uint param1 = 8;
        uint param2 = 7;
        uint param3 = 1;
        if (n >= min && n <= min + (param1 * (max - min)) / 100) {
            n = _bound2((x * (10 ** param2 + param3)) / 10 ** param2, min, max);
        }

        return n;
    }

    // To restrict fuzz test when we don't need all 'runs' iterations
    // usage: if (!mustExecuteTest(randomNumber, max)) return;
    /// @param randomNumber a random number, a fuzz test parameter
    // number = bound(number, 2 ** 99, 2 ** 100 - 1); small enough to support multiplication
    /// @param max must be < runs
    /// @param runs defined in foundry.toml
    /// @param withFfi use random with ffi or bound
    function mustExecuteTest(
        uint256 randomNumber,
        uint256 max,
        uint256 runs,
        bool withFfi
    ) public returns (bool) {
        assert(max < runs);
        uint256 number;
        if (withFfi) {
            number = getRandomNumber(1, runs);
        } else {
            number = bound2(randomNumber, 1, runs);
        }

        uint param = 120;

        return number <= (max * param) / 100;
    }

    function getRevertMsg(bytes memory _data) public pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_data.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            _data := add(_data, 0x04)
        }
        return abi.decode(_data, (string)); // All that remains is the revert string
    }

    function readFoundryTomlValue(
        string memory profileName,
        string memory varName
    ) public returns (uint256) {
        bool isGoodProfile = false;
        string memory line = "";
        vm.closeFile("./foundry.toml");
        uint256 lineNumber = 0;
        uint256 maxLineLength = 400;

        while (!isGoodProfile && lineNumber <= maxLineLength) {
            line = vm.readLine("./foundry.toml");
            if (
                bytes(line).length > 0 &&
                !areStringsEquals(slice(1, 1, line), "#") &&
                areStringsEquals(line, profileName)
            ) isGoodProfile = true;

            lineNumber++;
        }

        bool isGoodLine = false;

        while (!isGoodLine && lineNumber <= maxLineLength) {
            line = vm.readLine("./foundry.toml");
            if (
                bytes(line).length > 0 &&
                !areStringsEquals(slice(1, 1, line), "#") &&
                !areStringsEquals(slice(1, 1, line), "[") &&
                areStringsEquals(slice(1, bytes(varName).length, line), varName)
            ) isGoodLine = true;

            lineNumber++;
        }

        return vm.parseUint(slice(bytes(varName).length + 4, bytes(line).length, line));
    }

    function _toMemory(uint256[] storage a) internal view returns (uint256[] memory) {
        uint256[] memory b = new uint256[](a.length);
        for (uint n = 0; n < a.length; n++) {
            b[n] = a[n];
        }

        return b;
    }
}
