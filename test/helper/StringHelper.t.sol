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
        initialiseStorages();
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
    function test4removeUselessZeros() public {
        string memory str = "0x0000f78";

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
            //assertEq(t.removeUselessZeros(str), "0xf78");

        // equiv. error
        //assertTrue(areStringsEquals(t.removeUselessZeros(str), "0xf78"));
    }*/

    function testIsContain() public {
        // string
        string memory whereString = "A { sentence with ;";
        assertTrue(t.isContain("{", whereString));
        assertTrue(t.isContain("sentence", whereString));
        assertFalse(t.isContain("boat", whereString));

        // array
        string[] memory whereArray = new string[](3);
        whereArray[0] = "azerty";
        whereArray[1] = "qwerty";
        whereArray[2] = "apple";

        assertTrue(t.isContain("azerty", whereArray));
        assertFalse(t.isContain("boat", whereArray));
    }

    function testGetPositionStringContained() public {
        string memory whereString = "A { sentence with ;";
        assertEq(t.getPositionStringContained("A", whereString), 1);
        assertEq(t.getPositionStringContained("sentence", whereString), 5);
        assertEq(t.getPositionStringContained("boat", whereString), 0);
    }

    function testFindFirstCharPositionAfter() public {
        string memory whereString = "A { sentence with ;";
        assertEq(t.findFirstCharPositionAfter("A", 1, whereString), 1);
        assertEq(t.findFirstCharPositionAfter("w", 3, whereString), 14);
        assertEq(t.findFirstCharPositionAfter("b", 1, whereString), 0);
    }

    function testFindFirstCharPositionBefore() public {
        string memory whereString = "A { sentence with ;";
        uint whereStringLength = bytes(whereString).length;
        assertEq(
            t.findFirstCharPositionBefore(";", whereStringLength, whereString),
            whereStringLength
        );
        assertEq(t.findFirstCharPositionBefore("e", 14, whereString), 12);
        assertEq(t.findFirstCharPositionBefore("b", 14, whereString), 0);
    }

    function testHexStringToUint() public {
        assertEq(t.hexStringToUint("e"), 14);
        assertEq(t.hexStringToUint("10"), 16);
        vm.expectRevert("Invalid input");
        t.hexStringToUint(";");
    }

    function testHexString8ToBytes4() public {
        assertTrue(
            areStringsEquals(
                vm.toString(t.hexString8ToBytes4("fb969b0a")),
                vm.toString(bytes4(hex"fb969b0a"))
            )
        );
        vm.expectRevert("Invalid input");
        t.hexString8ToBytes4("fbF69b0a");
    }
}
