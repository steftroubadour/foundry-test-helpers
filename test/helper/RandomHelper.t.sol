// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test } from "forge-std/Test.sol";
import { RandomHelper } from "src/helper/RandomHelper.sol";
import { FuzzRecorder } from "src/recorder/FuzzRecorder.sol";
import { TestHelper } from "src/helper/TestHelper.sol";

contract RandomHelper_Test is Test, TestHelper, RandomHelper, FuzzRecorder {
    function setUp() public {
        assertTrue(IS_TEST);

        // Uncomment to debug tests
        //_initDebug();
    }

    function _initDebug() internal {
        debug = true;

        // To use VarRecorder
        _initialiseStorages();
        runs = _readFoundryTomlValue("[fuzz]", "runs");
    }

    function test_getRandomNumber_smallestRange(uint256) public {
        uint256 min = 0;
        uint256 max = 1;
        uint256 randomNumber = _getRandomNumber(min, max);
        assertGe(randomNumber, min);
        assertLe(randomNumber, max);
        // To see if sequence is really random
        // Erase test.txt file and uncomment next line
        //_writeNewLine("test.txt", string.concat("randomNumber: ", vm.toString(randomNumber)));
    }

    function test_getRandomNumber_smallRange(uint256) public {
        uint256 min = 1;
        uint256 max = 5;
        uint256 randomNumber = _getRandomNumber(min, max);
        assertGe(randomNumber, min);
        assertLe(randomNumber, max);
        // To see if sequence is really random
        // Erase test.txt file and uncomment next line
        //_writeNewLine("test.txt", string.concat("randomNumber: ", vm.toString(randomNumber)));
    }

    function test_getRandomNumber(uint256 min, uint256 max) public {
        min = bound(min, 0, 1000);
        max = bound(max, min, 10 ** 9);
        uint256 randomNumber = _getRandomNumber(min, max);
        assertGe(randomNumber, min);
        assertLe(randomNumber, max);
    }

    // todo, for best tests, improve using statistics calculations, recording random data in a file
    // ☢️Test will be slow, but there is not other way to do this

    function test_getDifferentRandomNumbers(uint256 n, uint256 min, uint256 max) public {
        uint256 maxDifferentNumbers = 20;
        n = bound(n, 5, maxDifferentNumbers);
        min = bound(min, 0, 1000);
        // ensure enough large range between min and max : min + maxDifferentNumbers * 10
        max = bound(max, min + maxDifferentNumbers + 10, 10 ** 6);

        //################ DEBUG ####################
        if (debug) {
            string memory testName;
            string memory logFile;
            string memory counterName;
            testName = "test_getDifferentRandomNumbers";
            logFile = string.concat(testName, ".md");
            counterName = string.concat(testName, "-", fuzzStorages[0]);
            if (!_isVarExist(counterName)) {
                _writeNewFile(logFile, "");
                _writeNewLine(logFile, string.concat("# ", testName, " logs"));
                _writeNewLine(logFile, string.concat("runs ", vm.toString(runs)));
                _writeNewLine(logFile, "");
                string[] memory data = new string[](3);
                data[0] = "n";
                data[1] = "min";
                data[2] = "max";
                _newTable(counterName, logFile, data);
            }

            string[] memory data = new string[](3);
            data[0] = vm.toString(n);
            data[1] = vm.toString(min);
            data[2] = vm.toString(max);
            _writeLogInTable(counterName, logFile, data);
        }
        //###########################################

        uint256[] memory randomNumbers = _getDifferentRandomNumbers(n, min, max);

        bool isAlreadyPresent;

        for (uint256 i; i < randomNumbers.length; i++) {
            for (uint256 j; j < randomNumbers.length; j++) {
                if (j == i) continue;
                if (randomNumbers[i] == randomNumbers[j]) {
                    isAlreadyPresent = true;
                }
            }
        }

        assertFalse(isAlreadyPresent);
    }

    function test_getDifferentRandomNumbers_withSmallRange(
        uint256 n,
        uint256 min,
        uint256 max
    ) public {
        string memory testName;
        string memory logFile;
        string memory counterName;
        if (debug) {
            testName = "test_getDifferentRandomNumbers_withSmallRange";
            logFile = string.concat(testName, ".md");
            counterName = string.concat(testName, "-", fuzzStorages[0]);
            if (!_isVarExist(counterName)) {
                _writeNewFile(logFile, "");
                _writeNewLine(logFile, string.concat("# ", testName, " logs"));
                _writeNewLine(logFile, string.concat("runs ", vm.toString(runs)));
                _writeNewLine(logFile, "");
                string[] memory data = new string[](3);
                data[0] = "n";
                data[1] = "min";
                data[2] = "max";
                _newTable(counterName, logFile, data);
            }
        }

        uint256 maxDifferentNumbers = 20;
        n = bound(n, 2, maxDifferentNumbers);
        min = bound(min, 0, 1000);
        max = min + n + 3;

        if (debug) {
            string[] memory data = new string[](3);
            data[0] = vm.toString(n);
            data[1] = vm.toString(min);
            data[2] = vm.toString(max);
            _writeLogInTable(counterName, logFile, data);
        }

        uint256[] memory randomNumbers = _getDifferentRandomNumbers(n, min, max);

        bool isAlreadyPresent;

        for (uint256 i; i < randomNumbers.length; i++) {
            for (uint256 j; j < randomNumbers.length; j++) {
                if (j == i) continue;
                if (randomNumbers[i] == randomNumbers[j]) {
                    isAlreadyPresent = true;
                }
            }
        }

        assertFalse(isAlreadyPresent);
    }
}
