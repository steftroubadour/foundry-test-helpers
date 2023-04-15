// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Test } from "forge-std/Test.sol";
import { RandomHelper } from "../helper/RandomHelper.sol";

// Use to record data between tests, to pass data to another test
abstract contract VarRecorder is RandomHelper {
    bool internal debug;

    string[] internal testStorages;
    string[] internal fuzzStorages;
    string[] internal helpStorages;

    function initialiseStorages() public {
        for (uint256 i; i < 10; i++) {
            testStorages.push(vm.toString(getRandomNumber(10 ** 18, 10 ** 19 - 1)));
        }

        for (uint256 j; j < 10; j++) {
            fuzzStorages.push(vm.toString(getRandomNumber(10 ** 17, 10 ** 18 - 1)));
        }

        for (uint256 j; j < 10; j++) {
            helpStorages.push(vm.toString(getRandomNumber(10 ** 16, 10 ** 17 - 1)));
        }
    }

    function getVarPath(string memory name) public pure returns (string memory) {
        return string.concat("./records/", name, ".txt");
    }

    function closeVar(string memory name) public {
        vm.closeFile(getVarPath(name));
    }

    function removeVar(string memory name) public {
        vm.removeFile(getVarPath(name));
    }

    function isVarExist(string memory name) public view returns (bool) {
        bool _isVarExist;
        try vm.readFile(getVarPath(name)) {
            _isVarExist = true;
        } catch {}

        return _isVarExist;
    }

    function readUintVar(string memory name) public returns (uint256) {
        string memory path = getVarPath(name);
        vm.closeFile(path);

        return vm.parseUint(vm.readLine(path));
    }

    function incrementUintVar(string memory name) public {
        uint256 value = readUintVar(name);

        vm.writeFile(getVarPath(name), vm.toString(++value));
    }

    function initializeUintVar(string memory name, uint256 value) public {
        vm.writeFile(getVarPath(name), vm.toString(value));
    }

    function getStoragePath(string memory name) public pure returns (string memory) {
        return string.concat("./records/", name, ".json");
    }

    function closeStorage(string memory name) public {
        vm.closeFile(getStoragePath(name));
    }

    function removeStorage(string memory name) public {
        vm.removeFile(getStoragePath(name));
    }

    function isStorageInUse(string memory name) public view returns (bool) {
        bool _isStorageInUse;

        try vm.readFile(getStoragePath(name)) {
            _isStorageInUse = true;
        } catch {}

        return _isStorageInUse;
    }

    function initStorage(string memory name) public {
        string memory path = getStoragePath(name);
        if (isStorageInUse(name)) return;

        vm.writeJson("{}", path);
    }

    function initStorage(string memory name, string[] memory keys) public {
        string memory path = getStoragePath(name);

        if (isStorageInUse(name)) return;

        string memory jsonObj = "json";
        string memory finalJson;
        for (uint256 i; i < keys.length; i++) {
            finalJson = vm.serializeUint(jsonObj, keys[i], 0);
        }
        vm.writeJson(finalJson, path);
    }

    function readStorageUintKey(string memory name, string memory key) public returns (uint256) {
        string memory path = getStoragePath(name);
        vm.closeFile(path);
        string memory jsonFile = vm.readFile(path);

        return vm.parseJsonUint(jsonFile, string.concat(".", key));
    }

    function saveStorageUintKey(string memory name, string memory key, uint256 value) public {
        string memory path = getStoragePath(name);

        if (!isStorageInUse(name)) return;

        vm.writeJson(vm.toString(value), path, string.concat(".", key));
    }

    function incrementStorageUintKey(string memory name, string memory key) public {
        string memory path = getStoragePath(name);
        uint256 value = readStorageUintKey(name, key);
        vm.closeFile(path);
        saveStorageUintKey(name, key, ++value);
    }
}
