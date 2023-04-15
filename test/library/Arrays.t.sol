// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test } from "forge-std/Test.sol";
import { Arrays, Bits } from "src/library/Libraries.sol";
import { Helpers } from "src/helper/Helpers.sol";

contract Arrays_Test is Test, Helpers {
    uint256[] public a;
    uint256[] public b;

    function setUp() public {
        assertTrue(IS_TEST);
    }

    function test4areEquals() public {
        a = [0, 1, 2, 3, 4];
        b = [0, 1, 2, 3, 4];

        assertTrue(Arrays.areEquals(_toMemory(a), _toMemory(b)));

        b[3] = 1;
        assertFalse(Arrays.areEquals(_toMemory(a), _toMemory(b)));
    }

    function test4areEquals_uint8() public {
        uint8[] memory a8 = new uint8[](4);
        a8[0] = 0;
        a8[1] = 1;
        a8[2] = 2;
        a8[3] = 3;
        uint8[] memory b8 = new uint8[](4);
        b8[0] = 0;
        b8[1] = 1;
        b8[2] = 2;
        b8[3] = 3;

        assertTrue(Arrays.areEquals(a8, b8));

        b8[3] = 1;
        assertFalse(Arrays.areEquals(a8, b8));
    }

    function test4areEquals(uint number, uint length) public {
        length = bound(length, 1, 32);
        number = bound(number, 2 ** 255, type(uint256).max);
        uint256[] memory _a = Arrays.uintToArray(number, length);
        uint256[] memory _b = Arrays.uintToArray(number, length);

        assertTrue(Arrays.areEquals(_a, _b));

        _b[length - 1]++;
        assertFalse(Arrays.areEquals(_a, _b));
    }

    function test4toString() public {
        a = [uint(1), 2, 3];
        assertEq(Arrays.toString(_toMemory(a)), "[1, 2, 3](3)");
    }

    function test4toString_uint8() public {
        a = [uint(1), 2, 3];
        assertEq(Arrays.toString(Arrays.toUint8Array(_toMemory(a))), "[1, 2, 3](3)");
    }
}
