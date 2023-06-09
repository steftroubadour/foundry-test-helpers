// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";
import { Test, StdStorage, stdStorage, console } from "forge-std/Test.sol";

abstract contract StorageHelper is Test {
    using stdStorage for StdStorage;

    // How to use
    //////////////////
    // vm.record();
    // do_something_that_must_record_a_value_in_storage();
    // bytes32[] memory lastWrittenSlots = getLastWrittenSlots(contractAddress);
    //
    // assertEq(lastWrittenSlots.length, 1); // one value expected
    // lastWrittenSlots[0] is the bytes32 slot value.
    // You can retrieve value with vm.load(contractAddress, lastWrittenSlots[0]);
    function getLastWrittenSlots(address contractAddress) public returns (bytes32[] memory) {
        (, bytes32[] memory writes) = vm.accesses(contractAddress);
        return writes;
    }

    function getLastReadSlots(address contractAddress) public returns (bytes32[] memory) {
        (bytes32[] memory reads, ) = vm.accesses(contractAddress);
        return reads;
    }

    /*function _readSlots(address contractAddress) public view {
        bytes32 value;
        uint256 i;
        while ((value = vm.load(contractAddress, bytes32(i))) != bytes32(0)) {
            console.log("value@slot[%s] = %s", i, uint256(vm.load(contractAddress, bytes32(i))));
            i++;
        }
    }

    function _readSlots(address contractAddress, uint256 length) public view {
        for (uint256 i = 0; i < length; i++) {
            console.log("value@slot[%s] = %s", i, uint256(vm.load(contractAddress, bytes32(i))));
        }
    }*/

    /*
    mapping(address => uint256) writesLengths;
    mapping(address => uint256) readsLengths;

    struct Key {
        string keyType;
        bytes32 keyValue;
    }

    function retrieveSlotAndValue(
        address target,
        string memory selector,
        Key memory key0
    ) public returns (uint256, bytes32 value) {
        Key[5] memory keys; // fixed size to avoid error
        keys[0] = key0;

        StdStorage storage store = stdstore.target(target).sig(selector);

        for (uint8 i = 0; i < keys.length; i++) {
            if (keccak256(abi.encode(keys[i].keyType)) == keccak256(abi.encode("uint256"))) {
                store = store.with_key(uint256(keys[i].keyValue));
            } else if (keccak256(abi.encode(keys[i].keyType)) == keccak256(abi.encode("bytes32"))) {
                store = store.with_key(keys[i].keyValue);
            } else if (keccak256(abi.encode(keys[i].keyType)) == keccak256(abi.encode("bytes28"))) {
                store = store.with_key(bytes28(keys[i].keyValue));
            } else if (keccak256(abi.encode(keys[i].keyType)) == keccak256(abi.encode("bytes4"))) {
                store = store.with_key(bytes4(keys[i].keyValue));
            } else {}
        }

        uint256 slot = store.find();

        return (slot, vm.load(target, bytes32(slot)));
    }

    // to use with vm.record();
    function storageActions(address contractAddress) public {
        (bytes32[] memory reads, bytes32[] memory writes) = vm.accesses(contractAddress);

        if (
            writes.length == writesLengths[contractAddress] &&
            reads.length == readsLengths[contractAddress]
        ) {
            console.log("nothing written or read");
            return;
        }

        if (writes.length > writesLengths[contractAddress]) {
            for (uint256 i = 0; i < writes.length - writesLengths[contractAddress]; i++) {
                console.log(
                    "@slot:%s write %s",
                    Strings.toHexString(uint256(writes[i])),
                    Strings.toHexString(uint256(vm.load(contractAddress, writes[i])))
                );
            }
        }

        if (reads.length > readsLengths[contractAddress]) {
            for (uint256 i = 0; i < reads.length - readsLengths[contractAddress]; i++) {
                console.log(
                    "@slot:%s read %s",
                    Strings.toHexString(uint256(reads[i])),
                    Strings.toHexString(uint256(vm.load(contractAddress, reads[i])))
                );
            }
        }

        writesLengths[contractAddress] = writes.length;
        readsLengths[contractAddress] = reads.length;
    }*/
}
