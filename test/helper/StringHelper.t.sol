// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test } from "forge-std/Test.sol";
import { StringHelper } from "src/helper/StringHelper.sol";
import { FuzzRecorder } from "src/recorder/FuzzRecorder.sol";
import { VarRecorder } from "src/recorder/VarRecorder.sol";
import { TestHelper } from "src/helper/TestHelper.sol";

contract StringHelper_ is StringHelper {}

contract StringHelper_Test is Test, TestHelper, VarRecorder, FuzzRecorder {
    StringHelper_ t;

    function setUp() public {
        assertTrue(IS_TEST);

        t = new StringHelper_();
        // Uncomment to debug tests
        //_initDebug();
    }

    function _initDebug() internal {
        debug = true;

        // To use VarRecorder
        _initialiseStorages();
        runs = readFoundryTomlValue("[fuzz]", "runs");
    }

    function test4areStringsEquals() public {
        string memory str1 = "a string";
        string memory str2 = "a string";
        assertTrue(t.areStringsEquals(str1, str2));

        str1 = "a string";
        str2 = "another string";
        assertFalse(t.areStringsEquals(str1, str2));
    }

    function test4isEmptyString() public {
        string memory str = "";
        assertTrue(t.isEmptyString(str));

        str = "a string";
        assertFalse(t.isEmptyString(str));
    }

    function test4slice() public {
        string memory str = "a long string to test"; // 21 char
        assertEq(t.slice(1, 3, str), "a l");
        assertEq(t.slice(16, 21, str), "o test");
        assertEq(t.slice(6, 17, str), "g string to ");
    }

    function test4remove0x() public {
        string memory str = "0x123De4f78";
        assertEq(t.remove0x(str), "123De4f78");
    }

    /*

Traces:
  [26685] StringHelper_Test::test4removeUselessZeros()
    ├─ [3616] StringHelper_::removeUselessZeros(0x0000f78) [staticcall]
    │   └─ ← 0xf78
    ├─ emit log(: Error: a == b not satisfied [string])
    ├─ emit log_named_string(key:       Left, val: 0xf78)
    ├─ emit log_named_string(key:      Right, val: 0xf78)
    ├─ [0] VM::store(VM: [0x7109709ECfa91a80626fF3989D68f67F5b1DD12D], 0x6661696c65640000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000001)
    │   └─ ← ()
    └─ ← ()

    function test4removeUselessZeros() public {
        string memory str = "0x0000f78";
        assertEq(t.removeUselessZeros(str), "0xf78");
    }*/
}
