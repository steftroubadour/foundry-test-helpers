// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Test, console } from "forge-std/Test.sol";
import { VarRecorder } from "src/recorder/VarRecorder.sol";
import { TestHelper } from "src/helper/TestHelper.sol";

contract VarRecorder_ is VarRecorder {
    function getTestStorage(uint index) public view returns (string memory) {
        return testStorages[index];
    }

    function getFuzzStorage(uint index) public view returns (string memory) {
        return fuzzStorages[index];
    }
}

contract VarRecorder_Test is Test, TestHelper {
    VarRecorder_ t;
    // in fuzz tests
    uint256 runs;

    // in invariants tests
    //...

    function setUp() public {
        t = new VarRecorder_();

        runs = readFoundryTomlValue("[fuzz]", "runs");

        t.initialiseStorages();
    }

    function test_incrementUintVar() public {
        t.initializeUintVar(t.getTestStorage(1), 0);
        for (uint256 i; i < runs; i++) {
            t.incrementUintVar(t.getTestStorage(1));
        }

        assertEq(t.readUintVar(t.getTestStorage(1)), runs);

        vm.removeFile(t.getVarPath(t.getTestStorage(1)));
    }

    function test_incrementUintVar(uint256 randomNumber) public {
        assertEq(randomNumber, randomNumber);

        string memory uintVar = t.getTestStorage(2);
        if (t.isVarExist(uintVar)) {
            uint256 oldValue = t.readUintVar(uintVar);
            t.incrementUintVar(uintVar);
            uint256 newValue = t.readUintVar(uintVar);

            assertTrue(newValue == oldValue + 1);
        } else {
            // a way to do something one time in a fuzz test
            // But it takes a round of the fuzz ! runs - 1
            // Initialize when file doesn't exists
            t.initializeUintVar(uintVar, 0);
        }

        // End of the fuzz test
        if (t.readUintVar(uintVar) == runs - 1) {
            t.removeVar(uintVar);
        }
    }

    function test_initializeUintVar(uint256 number) public {
        // Example of usage of a fuzz counter
        // - Permit an initialization of fuzz test
        // - Permit to make stuff after the last iteration of the fuzz test
        // use an unused counter each time.
        string memory fuzzCounter = t.getFuzzStorage(0);

        string memory uintVar = t.getTestStorage(0);
        if (t.isVarExist(fuzzCounter)) {
            uint256 value = bound(number, 0, 1000);
            t.initializeUintVar(uintVar, value);
            assertTrue(t.readUintVar(uintVar) == value);

            t.incrementUintVar(fuzzCounter);
        } else {
            // a way to do something one time in a fuzz test
            // But it takes a round of the fuzz ! runs - 1
            // Initialize when file doesn't exists
            t.initializeUintVar(fuzzCounter, 0);
        }

        // Remove files at the end of the fuzz test
        if (t.readUintVar(fuzzCounter) == runs - 1) {
            t.removeVar(fuzzCounter);

            // remove var used
            t.removeVar(uintVar);
        }
    }

    function test_storeUintVar() public {
        string memory myStorage = t.getTestStorage(3);
        assertFalse(t.isStorageInUse(myStorage));
        string[] memory keys = new string[](2);
        keys[0] = "counter";
        keys[1] = "counter2";
        t.initStorage(myStorage, keys);

        assertTrue(t.isStorageInUse(myStorage));
        assertEq(t.readStorageUintKey(myStorage, "counter"), 0);
        assertEq(t.readStorageUintKey(myStorage, "counter2"), 0);

        t.saveStorageUintKey(myStorage, "counter", 111);
        assertEq(t.readStorageUintKey(myStorage, "counter"), 111);
        assertEq(t.readStorageUintKey(myStorage, "counter2"), 0);

        t.incrementStorageUintKey(myStorage, "counter");
        assertEq(t.readStorageUintKey(myStorage, "counter"), 112);
        assertEq(t.readStorageUintKey(myStorage, "counter2"), 0);

        t.removeStorage(myStorage);
        assertFalse(t.isStorageInUse(myStorage));
    }
}
