// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;
import "forge-std/Test.sol";
import { ArtifactHelper } from "src/helper/ArtifactHelper.sol";
import { StringHelper } from "src/helper/StringHelper.sol";

contract ArtifactHelper_ is ArtifactHelper {
    function setInputTypesFromArtifact(string memory json) public returns (string[] memory) {
        return _setInputTypesFromArtifact(json);
    }

    function functionIdentifierToSelector(
        string memory functionIdentifier
    ) public pure returns (bytes4) {
        return _functionIdentifierToSelector(functionIdentifier);
    }

    function retrieveFunctionsFromArtifact(
        string memory json
    ) public pure returns (ElementAbi[] memory) {
        return _retrieveFunctionsFromArtifact(json);
    }

    function retrieveMethodIdentifiersFromArtifact(
        string memory json
    ) public pure returns (string[] memory) {
        return _retrieveMethodIdentifiersFromArtifact(json);
    }

    function filterMethodIdentifiers(
        string[] memory ids,
        string[] memory functionExceptionIdentifiers
    ) public returns (string[] memory) {
        return _filterMethodIdentifiers(ids, functionExceptionIdentifiers);
    }

    function retrieveMethodIdentifierJsonFromArtifact(
        string memory json
    ) public pure returns (string memory) {
        return _retrieveMethodIdentifierJsonFromArtifact(json);
    }

    function retrieveSignatureFromArtifact(
        string memory json,
        string memory methodIdentifier
    ) public pure returns (string memory) {
        return _retrieveSignatureFromArtifact(json, methodIdentifier);
    }

    function retrieveSelectorFromElement(
        ElementAbi memory elementAbi
    ) public pure returns (bytes4) {
        return _retrieveSelectorFromElement(elementAbi);
    }

    function retrieveSignatureFromElement(
        ElementAbi memory elementAbi
    ) public pure returns (string memory) {
        return _retrieveSignatureFromElement(elementAbi);
    }

    function methodIdentifierFromSelector(bytes4 selector) public pure returns (string memory) {
        return _methodIdentifierFromSelector(selector);
    }
}

contract ArtifactHelperTest is Test, StringHelper {
    ArtifactHelper_ t;
    string artifact;

    function setUp() public {
        assertTrue(IS_TEST);

        t = new ArtifactHelper_();
        artifact = vm.readFile("test/utils/artifact.json");
    }

    function testSetInputTypesFromArtifact() public {
        string[] memory inputTypes = t.setInputTypesFromArtifact(artifact);
        assertEq(2, inputTypes.length);
        assertTrue(areStringsEquals(inputTypes[0], "bytes32"));
        assertTrue(areStringsEquals(inputTypes[1], "address"));
    }

    function testFunctionIdentifierToSelector() public {
        // hex"1234abcd" : 0x1234abcd00000000000000000000000000000000000000000000000000000000
        // bytes32(uint256(0x1234abcd)) : 0x000000000000000000000000000000000000000000000000000000001234abcd
        assertEq(
            bytes32(bytes4(hex"1234abcd")),
            bytes32(t.functionIdentifierToSelector("1234abcd"))
        );
    }

    function testRetrieveFunctionsFromArtifact() public {
        ArtifactHelper.ElementAbi[] memory functions = t.retrieveFunctionsFromArtifact(artifact);
        assertEq(functions.length, 7);
        for (uint i; i < functions.length; i++) {
            assertTrue(areStringsEquals(functions[i].type_, "function"));
        }
    }

    function testRetrieveMethodIdentifiersFromArtifact() public {
        string[] memory methodIdentifiers = t.retrieveMethodIdentifiersFromArtifact(artifact);
        assertEq(methodIdentifiers.length, 7);
        assertTrue(areStringsEquals(methodIdentifiers[0], "fb969b0a"));
        assertTrue(areStringsEquals(methodIdentifiers[1], "248a9ca3"));
        assertTrue(areStringsEquals(methodIdentifiers[2], "2f2ff15d"));
        assertTrue(areStringsEquals(methodIdentifiers[3], "91d14854"));
        assertTrue(areStringsEquals(methodIdentifiers[4], "36568abe"));
        assertTrue(areStringsEquals(methodIdentifiers[5], "d547741f"));
        assertTrue(areStringsEquals(methodIdentifiers[6], "dfde5e58"));
    }

    function testFilterMethodIdentifiers() public {
        string[] memory functionExceptionIdentifiers = new string[](2);
        functionExceptionIdentifiers[0] = "248a9ca3";
        functionExceptionIdentifiers[1] = "d547741f";
        string[] memory methodIdentifiers = t.retrieveMethodIdentifiersFromArtifact(artifact);
        string[] memory filteredIds = t.filterMethodIdentifiers(
            methodIdentifiers,
            functionExceptionIdentifiers
        );

        assertTrue(areStringsEquals(filteredIds[0], "fb969b0a"));
        assertTrue(areStringsEquals(filteredIds[1], "2f2ff15d"));
        assertTrue(areStringsEquals(filteredIds[2], "91d14854"));
        assertTrue(areStringsEquals(filteredIds[3], "36568abe"));
        assertTrue(areStringsEquals(filteredIds[4], "dfde5e58"));
    }

    function testRetrieveMethodIdentifierJsonFromArtifact() public {
        string memory json = t.retrieveMethodIdentifierJsonFromArtifact(artifact);

        assertEq(getPositionStringContained("{", json), 1); // first
        assertEq(getPositionStringContained("}", json), bytes(json).length); // last
        assertTrue(isContain('"bootstrap()": "fb969b0a",', json));
        assertTrue(isContain('"getRoleAdmin(bytes32)": "248a9ca3",', json));
        assertTrue(isContain('"grantRole(bytes32,address)": "2f2ff15d",', json));
        assertTrue(isContain('"hasRole(bytes32,address)": "91d14854",', json));
        assertTrue(isContain('"renounceRole(bytes32,address)": "36568abe",', json));
    }

    function testRetrieveSignatureFromArtifact() public {
        assertTrue(
            areStringsEquals(
                t.retrieveSignatureFromArtifact(artifact, "248a9ca3"),
                "getRoleAdmin(bytes32)"
            )
        );
    }

    function testRetrieveSelectorFromElement() public {
        ArtifactHelper.ElementAbi[] memory functions = t.retrieveFunctionsFromArtifact(artifact);
        assertEq(
            bytes32(t.retrieveSelectorFromElement(functions[2])),
            bytes32(bytes4(hex"2f2ff15d"))
        );
    }

    function testRetrieveSignatureFromElement() public {
        ArtifactHelper.ElementAbi[] memory functions = t.retrieveFunctionsFromArtifact(artifact);
        assertTrue(
            areStringsEquals(
                t.retrieveSignatureFromElement(functions[2]),
                "grantRole(bytes32,address)"
            )
        );
    }

    function testMethodIdentifierFromSelector() public {
        assertEq("2f2ff15d", t.methodIdentifierFromSelector(0x2f2ff15d));
    }
}
