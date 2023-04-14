// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console, Test, Vm } from "forge-std/Test.sol";
import { GasHelper } from "src/helper/GasHelper.sol";
import { ERC721, IERC721, IERC721Metadata, IERC165 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GasHelper_Test is Test, GasHelper {
    ERC721 nft;

    function setUp() public {
        assertTrue(IS_TEST);

        nft = new ERC721("name", "SYMBOL");
    }

    function itInterfaceGasConsumption(bytes4 interfaceSign, string memory interfaceName) internal {
        // #supportsInterface() must use less than 30 000 gas.

        string memory key;
        uint256 value;
        Vm.Log[] memory entries;

        startMeasuringGas(string.concat("#supportsInterface(", interfaceName, ")"));
        assertTrue(nft.supportsInterface(interfaceSign));
        stopMeasuringGas();
        // Consume the recorded logs when called.
        entries = vm.getRecordedLogs();
        // struct Log { bytes32[] topics; bytes data; }
        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("log_named_uint(string,uint256)"));
        assertEq(entries[0].topics.length, 1);
        (key, value) = abi.decode(entries[0].data, (string, uint256));
        assertLt(value, 30000);
    }

    function test4supportsInterface() public {
        vm.recordLogs();

        itInterfaceGasConsumption(type(IERC721).interfaceId, "IERC721");
        itInterfaceGasConsumption(type(IERC721Metadata).interfaceId, "IERC721Metadata");
        itInterfaceGasConsumption(type(IERC165).interfaceId, "IERC165");
    }
}
