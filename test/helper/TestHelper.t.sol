// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test } from "forge-std/Test.sol";
import { TestHelper } from "src/helper/Helpers.sol";
import { FuzzRecorder } from "src/recorder/FuzzRecorder.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestHelper_ is TestHelper {
    uint[] a = [1, 2, 3];

    function toMemory() public view returns (uint[] memory) {
        return _toMemory(a);
    }

    function getArrayValue(uint index) public view returns (uint) {
        return a[index];
    }
}

contract TestHelper_Test is Test, FuzzRecorder {
    TestHelper_ t;
    ERC721 nft;

    function setUp() public {
        assertTrue(IS_TEST);

        t = new TestHelper_();
        nft = new ERC721("a name", "SYMBOL");

        // Uncomment to debug tests
        //debug = true;

        // To use VarRecorder
        _initialiseStorages();
        runs = readFoundryTomlValue("[fuzz]", "runs");
    }

    function test_readFoundryTomlValue() public {
        assertEq(t.readFoundryTomlValue("[fuzz]", "runs"), 256);
        assertEq(t.readFoundryTomlValue("[invariant]", "runs"), 256);
        assertEq(t.readFoundryTomlValue("[invariant]", "depth"), 15);
    }

    function test_mustExecuteTest(uint256 number) public {
        string memory testName = "test_mustExecuteTest";
        string memory trueCounterName = string.concat(testName, "-true", fuzzStorages[1]);
        string memory iterationCounterName = string.concat(testName, "-iteration", fuzzStorages[2]);

        number = t.bound2(number, 10000, 99999); // small enough to support multiplication
        uint valueExpected = 10;
        bool mustExecuteTest = t.mustExecuteTest(number, valueExpected, runs, false);

        if (!_isVarExist(trueCounterName)) _initializeUintVar(trueCounterName, 0);
        if (!_isVarExist(iterationCounterName)) {
            _initializeUintVar(iterationCounterName, 1);
        } else {
            _incrementUintVar(iterationCounterName);
        }
        //// useful for 'forge coverage --report summary', don't know why !
        if (!_isVarExist("trueCounterName-runs")) _initializeUintVar("trueCounterName-runs", runs);
        ////

        if (mustExecuteTest) _incrementUintVar(trueCounterName);

        // Last iteration
        if (_readUintVar(iterationCounterName) == runs) {
            //uint param1 = 150;
            //uint param2 = 50;
            uint trueCounter = _readUintVar(trueCounterName);
            //assertLt(trueCounter, (valueExpected * param1) / 100);
            //assertGt(trueCounter, (valueExpected * param2) / 100);
            assertGt(trueCounter, 0);
            _removeVar(iterationCounterName);
            _removeVar(trueCounterName);
            _removeVar("trueCounterName-runs");
        }

        //################ DEBUG ####################
        if (debug) {
            string memory logFile;
            string memory counterName;
            logFile = string.concat(testName, ".md");
            counterName = string.concat(testName, "-", fuzzStorages[0]);
            string[] memory data;
            if (!_isVarExist(counterName)) {
                _writeNewFile(logFile, "");
                _writeNewLine(logFile, string.concat("# ", testName, " logs"));
                _writeNewLine(logFile, string.concat("runs ", vm.toString(runs)));
                _writeNewLine(logFile, "");
                data = new string[](1);
                data[0] = "mustExecuteTest";
                _newTable(counterName, logFile, data);
            }

            data = new string[](1);
            data[0] = vm.toString(mustExecuteTest);
            _writeLogInTable(counterName, logFile, data);
        }
        //###########################################
    }

    function test_toMemory() public {
        uint[] memory b = t.toMemory();
        bool areEquals = true;
        for (uint n = 0; n < b.length; n++) {
            if (t.getArrayValue(n) != b[n]) areEquals = false;
        }

        assertTrue(areEquals);
    }

    function test_getRevertMsg() public {
        (bool succeeded, bytes memory data) = address(nft).call(
            abi.encodeWithSignature("balanceOf(address)", address(0))
        );

        assertTrue(!succeeded);
        assertEq(t.getRevertMsg(data), "ERC721: address zero is not a valid owner");
    }
}
