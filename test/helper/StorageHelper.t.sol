// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test, Vm } from "forge-std/Test.sol";
import { StorageHelper } from "src/helper/StorageHelper.sol";

contract Example {
    uint256 public counter; // slot 0
    mapping(uint256 => address) private addresses;

    constructor() {
        counter = 123;
        addresses[200] = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }

    function setCounter(uint256 id) public {
        counter = id;
    }

    function getAddress(uint256 id) public view returns (address) {
        return addresses[id];
    }

    function setAddress(uint256 id, address addr) public {
        addresses[id] = addr;
    }
}

contract StorageHelper_ is StorageHelper {}

contract StorageHelper_Test is Test, StorageHelper {
    Example example;
    StorageHelper_ t;

    function setUp() public {
        assertTrue(IS_TEST);

        example = new Example();
        t = new StorageHelper_();
    }

    function test4_getLastReadSlots() public {
        vm.record();

        // Read
        uint256 returnedValue = example.counter();

        bytes32[] memory lastReadSlots = t.getLastReadSlots(address(example));

        assertEq(lastReadSlots.length, 1); // one value expected
        // lastReadSlots[0] is the bytes32 slot value.
        assertEq(uint256(vm.load(address(example), lastReadSlots[0])), returnedValue);

        // Each time vm.accesses is used in getLastReadSlots, records are reset.
        lastReadSlots = t.getLastReadSlots(address(example));
        assertEq(lastReadSlots.length, 0);

        address returnedAddress = example.getAddress(200);
        lastReadSlots = t.getLastReadSlots(address(example));
        assertEq(lastReadSlots.length, 1);
        assertEq(
            address(uint160(uint256(vm.load(address(example), lastReadSlots[0])))),
            returnedAddress
        );
    }

    function test4_getLastWrittenSlots() public {
        vm.record();

        // Write
        uint256 setValue = 32;
        example.setCounter(setValue);

        bytes32[] memory lastWrittenSlots = t.getLastWrittenSlots(address(example));

        assertEq(lastWrittenSlots.length, 1); // one value expected
        // lastReadSlots[0] is the bytes32 slot value.
        assertEq(uint256(vm.load(address(example), lastWrittenSlots[0])), setValue);

        // Each time vm.accesses is used in getLastWrittenSlots, records are reset.
        lastWrittenSlots = t.getLastWrittenSlots(address(example));
        assertEq(lastWrittenSlots.length, 0);

        address addressSet = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        example.setAddress(200, addressSet);
        lastWrittenSlots = t.getLastWrittenSlots(address(example));
        assertEq(lastWrittenSlots.length, 1);
        assertEq(
            address(uint160(uint256(vm.load(address(example), lastWrittenSlots[0])))),
            addressSet
        );
    }
}
