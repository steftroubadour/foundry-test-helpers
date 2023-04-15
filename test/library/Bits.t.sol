// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test } from "forge-std/Test.sol";
import { Arrays, Bits } from "src/library/Libraries.sol";
import { FuzzRecorder } from "src/recorder/FuzzRecorder.sol";

contract Bits_Test is Test, FuzzRecorder {
    uint256[] public bits;
    uint256[] public a;

    function setUp() public {
        assertTrue(IS_TEST);

        // Uncomment to debug tests
        //_initDebug();
    }

    function _initDebug() internal {
        debug = true;

        // To use VarRecorder
        initialiseStorages();
        runs = readFoundryTomlValue("[fuzz]", "runs");
    }

    function test4getNth8Bits() public {
        uint256 value = 123 * 256 * 256 + 34 * 256 + 126;

        assertEq(value, 8069758);
        assertEq(Bits.getNth8Bits(value, 0), 126);
        assertEq(Bits.getNth8Bits(value, 1), 34);
        assertEq(Bits.getNth8Bits(value, 2), 123);
    }

    function test4getNth8Bits(uint number) public {
        number = bound(number, 2 ** 255, type(uint256).max);
        uint256[] memory _a = Arrays.uintToArray(number, 32); // uint8[32] i.e. 32 values in [0; 255]
        // Construct value with expected values
        uint256 value = Arrays.toUint(Arrays.toUint8Array(_a));

        for (uint8 n = 0; n < 32; n++) {
            assertEq(Bits.getNth8Bits(value, n), _a[n]);
        }
    }

    function test4getLast8Bits(uint160 othersBits, uint8 last8Bits) public {
        uint256 number = bound(othersBits, 2 ** 159, type(uint160).max) * 256 + last8Bits;

        assertEq(Bits.getLast8Bits(number), last8Bits);
    }

    function test4getLastNBits(uint256 othersBits_, uint256 lastNBits_, uint256 n_) public {
        uint256 n = bound(n_, 1, 5);
        uint256 othersBits = bound(othersBits_, 1, (1 << 6) - 1);
        uint256 lastNBits = bound(lastNBits_, 0, (1 << n) - 1);
        uint number = (othersBits << n) + lastNBits;

        //################ DEBUG ####################
        if (debug) {
            string memory testName;
            string memory logFile;
            string memory counterName;
            string[] memory data;
            testName = "test4getLastNBits";
            logFile = string.concat(testName, ".md");
            counterName = string.concat(testName, "-", fuzzStorages[0]);
            if (!isVarExist(counterName)) {
                writeNewFile(logFile, "");
                writeNewLine(logFile, string.concat("# ", testName, " logs"));
                writeNewLine(logFile, "");
                data = new string[](4);
                data[0] = "n";
                data[1] = "othersBits";
                data[2] = "lastNBits";
                data[3] = "number";
                newTable(counterName, logFile, data);
            }

            data = new string[](4);
            data[0] = vm.toString(n);
            data[1] = vm.toString(othersBits);
            data[2] = vm.toString(lastNBits);
            data[3] = vm.toString(number);
            writeDataInTable(counterName, logFile, data);
        }
        //###########################################

        assertEq(Bits.getLastNBits(number, n), lastNBits);
    }

    function test4arrayOfBitsToString() public {
        bits = [0, 1, 1, 1, 0, 1, 1, 0, 0, 1];

        assertEq(Bits.arrayOfBitsToString(Arrays.toUint8Array(_toMemory(bits))), "10-01101110");
    }

    function test4toArrayOfBits() public {
        uint256 number = 0 *
            2 ** 0 +
            0 *
            2 ** 1 +
            1 *
            2 ** 2 +
            1 *
            2 ** 3 +
            0 *
            2 ** 4 +
            1 *
            2 ** 5; // 44

        a = [0, 0, 1, 1, 0, 1];
        uint8[] memory expectedArray = Arrays.toUint8Array(
            Arrays.completeWithZeros(_toMemory(a), 256)
        );
        assertTrue(Arrays.areEquals(Bits.toArrayOfBits(number), expectedArray));
    }

    function test4getRangeOfBits() public {
        bits = [0, 0, 1, 1, 0, 1];
        uint256 number = Bits.toNumber(Arrays.toUint8Array(_toMemory(bits)));

        assertEq(number, 44);
        assertEq(Bits.getRangeOfBits(number, 1, 6), number);
        bits = [0, 0, 0, 1, 0, 1];
        assertEq(
            Bits.getRangeOfBits(number, 4, 6),
            Bits.toNumber(Arrays.toUint8Array(_toMemory(bits)))
        );
        bits = [0, 0, 0, 1, 0, 0];
        assertEq(
            Bits.getRangeOfBits(number, 4, 5),
            Bits.toNumber(Arrays.toUint8Array(_toMemory(bits)))
        );
    }

    function test4sliceBits() public {
        bits = [0, 0, 1, 1, 0, 1];
        uint256 number = Bits.toNumber(Arrays.toUint8Array(_toMemory(bits)));

        assertEq(number, 44);
        assertEq(Bits.sliceBits(number, 1, 6), number);
        bits = [0, 1, 1, 0, 1];
        assertEq(Bits.sliceBits(number, 2, 6), Bits.toNumber(Arrays.toUint8Array(_toMemory(bits))));
        bits = [1, 1];
        assertEq(Bits.sliceBits(number, 3, 4), Bits.toNumber(Arrays.toUint8Array(_toMemory(bits))));
    }

    function test4toNumber() public {
        bits = [0, 0, 1, 1, 0, 1];
        uint256 number = Bits.toNumber(Arrays.toUint8Array(_toMemory(bits)));
        assertEq(number, 44);

        bits = [1, 0, 1, 1];
        number = Bits.toNumber(Arrays.toUint8Array(_toMemory(bits)));
        assertEq(number, 13);
    }
}
