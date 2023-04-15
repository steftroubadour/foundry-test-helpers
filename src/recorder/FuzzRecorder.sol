// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Test, Vm } from "forge-std/Test.sol";
import { Helpers } from "../helper/Helpers.sol";
import { VarRecorder } from "src/recorder/VarRecorder.sol";

// Use to record data during the same test
abstract contract FuzzRecorder is Test, Helpers, VarRecorder {
    bool internal record;
    bool internal displayRecords;

    uint256 public runs;

    /*struct Log {
        bytes32[] topics;
        bytes data;
        address emitter;
    }*/
    /*Vm.Log[] internal _logs;

    // Store logs in memory
    function storeLogs() public {
        Vm.Log[] memory logs;
        logs = vm.getRecordedLogs();

        for (uint256 i; i < logs.length; i++) {
            _logs.push(logs[i]);
        }
    }

    // Serialize logs
    function serializeLogs() public returns (string memory) {
        */ /*struct Log {
            bytes32[] topics;
            bytes data;
            address emitter;
        }*/ /*

        string memory finalJson = "[";
        for (uint256 i; i < _logs.length; i++) {
            Vm.Log memory log = _logs[i];
            // write a log
            // Serialize log
            string memory obj1 = "log object";
            vm.serializeBytes32(obj1, "topics", log.topics);
            vm.serializeBytes(obj1, "data", log.data);
            string memory logJson = vm.serializeAddress(obj1, "emitter", log.emitter);
            finalJson = string.concat(finalJson, logJson);

            if (i < _logs.length - 1) {
                finalJson = string.concat(finalJson, ", ");
            }
        }

        return string.concat(finalJson, "]");
    }

    function printLogs() public {
        // ...
    }

    // Save logs in a file
    function saveLogs() public {
        // logs must be stored before : storeLogs();
        vm.writeJson(serializeLogs(), "./output/records.json");
    }*/

    function writeNewFile(string memory filename, string memory data) public {
        vm.writeFile(string.concat("./records/", filename), data);
    }

    // Used to debug fuzz test
    // Erase debug.txt before
    //writeNewLine("debug.txt", string.concat("tokenId: ", vm.toString(tokenId)));
    function writeNewLine(string memory filename, string memory data) public {
        vm.writeLine(string.concat("./records/", filename), data);
    }

    function newTable(
        string memory counterName,
        string memory fileName,
        string[] memory data
    ) public {
        initializeUintVar(counterName, 0); // var exist now & it's the first run

        string memory headLine = "| # |";
        string memory headLineSeparator = "|-----|";
        for (uint256 i; i < data.length; i++) {
            headLine = string.concat(headLine, " ", data[i], " |");
            headLineSeparator = string.concat(headLineSeparator, "-----------|");
        }

        writeNewLine(fileName, "");
        writeNewLine(fileName, headLine);
        writeNewLine(fileName, headLineSeparator);
    }

    function writeDataInTable(
        string memory counterName,
        string memory fileName,
        string[] memory data
    ) public {
        incrementUintVar(counterName);

        uint256 iteration = readUintVar(counterName);
        string memory line = string.concat("| ", vm.toString(iteration), " |");
        for (uint256 i; i < data.length; i++) {
            line = string.concat(line, " ", data[i], " | ");
        }

        writeNewLine(fileName, line);

        // End of the fuzz test
        if (iteration == runs) removeVar(counterName);
    }
}
