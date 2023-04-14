// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test } from "forge-std/Test.sol";
import { TestHelper } from "src/helper/TestHelper.sol";

contract TestHelper_Test is Test, TestHelper {
    function setUp() public {
        assertTrue(IS_TEST);
    }

    function test4_readFoundryTomlValue() public {
        assertEq(_readFoundryTomlValue("[fuzz]", "runs"), 256);
        assertEq(_readFoundryTomlValue("[invariant]", "runs"), 256);
        assertEq(_readFoundryTomlValue("[invariant]", "depth"), 15);
    }
}
