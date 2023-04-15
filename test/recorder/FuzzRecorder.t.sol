// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Test, console } from "forge-std/Test.sol";
import { FuzzRecorder, VarRecorder } from "src/recorder/FuzzRecorder.sol";
import { TestHelper } from "src/helper/TestHelper.sol";

contract FuzzRecorder_ is FuzzRecorder {}

contract FuzzRecorder_Test is Test, TestHelper, VarRecorder {
    FuzzRecorder_ t;
    // in fuzz tests
    uint256 runs;

    // in invariants tests
    //...

    function setUp() public {
        t = new FuzzRecorder_();

        runs = readFoundryTomlValue("[fuzz]", "runs");

        initialiseStorages();
    }

    function test_writeNewFile() public {
        t.writeNewFile("fileName.txt", "A new File");
        assertEq(vm.readFile("./records/fileName.txt"), "A new File");

        vm.removeFile("./records/fileName.txt");
    }

    function test_writeNewLine() public {
        t.writeNewFile("fileName2.txt", "");
        t.writeNewLine("fileName2.txt", "A new Line");
        assertTrue(areStringsEquals(vm.readLine("./records/fileName2.txt"), "A new Line"));

        vm.removeFile("./records/fileName2.txt");
    }
}
