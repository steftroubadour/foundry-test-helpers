// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "forge-std/Test.sol";
import { StringHelper } from "./StringHelper.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

abstract contract ArtifactHelper is StringHelper {
    using Strings for uint256;
    using stdJson for string;
    // methodIdentifier => data
    mapping(string => FunctionData) methods;

    string[] inputTypes;

    string[] tempStringArray;

    struct FunctionData {
        bytes4 selector;
        address impl;
        string signature;
        uint256 functionId;
    }

    struct SubElementAbi {
        string internalType;
        string name;
        string type_;
    }

    struct ElementAbi {
        SubElementAbi[] inputs;
        string name;
        SubElementAbi[] outputs;
        string stateMutability;
        string type_;
    }

    function _setInputTypesFromArtifact(string memory json) internal returns (string[] memory) {
        bytes memory typesBytes = json.parseRaw(
            //'$.abi[?(@.type == "function" && (@.stateMutability == "nonpayable" || @.stateMutability == "payable"))].inputs[*].type'
            '$.abi[?(@.type == "function")].inputs[*].type'
        );

        string[] memory types = abi.decode(typesBytes, (string[]));
        delete typesBytes;

        bool isAlreadyPresent;
        uint id;

        if (types.length == 0) return types;
        if (id == 0) inputTypes.push(types[0]);
        id++;
        for (uint i = 1; i < types.length; i++) {
            for (uint j; j < inputTypes.length; j++) {
                if (areStringsEquals(types[i], inputTypes[j])) isAlreadyPresent = true;
            }

            if (!isAlreadyPresent) {
                inputTypes.push(types[i]);
                id++;
            }

            isAlreadyPresent = false;
        }

        return inputTypes;
    }

    function _functionIdentifierToSelector(
        string memory functionIdentifier
    ) internal pure returns (bytes4) {
        return hexString8ToBytes4(functionIdentifier);
    }

    function _retrieveFunctionsFromArtifact(
        string memory json
    ) internal pure returns (ElementAbi[] memory) {
        bytes memory functions = json.parseRaw('.abi.[?(@.type == "function")]');
        return abi.decode(functions, (ElementAbi[]));
    }

    function _retrieveMethodIdentifiersFromArtifact(
        string memory json
    ) internal pure returns (string[] memory) {
        bytes memory functions = json.parseRaw(".methodIdentifiers.*");
        return abi.decode(functions, (string[]));
    }

    function _filterMethodIdentifiers(
        string[] memory ids,
        string[] memory functionExceptionIdentifiers
    ) internal returns (string[] memory) {
        for (uint i = 0; i < ids.length; i++) {
            // require not an exception
            if (isContain(ids[i], functionExceptionIdentifiers)) continue;

            tempStringArray.push(ids[i]);
        }
        string[] memory identifiers = new string[](tempStringArray.length);
        for (uint i = 0; i < tempStringArray.length; i++) {
            identifiers[i] = tempStringArray[i];
        }

        delete tempStringArray;

        return identifiers;
    }

    function _retrieveMethodIdentifierJsonFromArtifact(
        string memory json
    ) internal pure returns (string memory) {
        uint startPosition = getPositionStringContained("methodIdentifiers", json);
        uint end = findFirstCharPositionAfter("}", startPosition, json);
        return slice(startPosition + 20, end, json);
    }

    function _retrieveSignatureFromArtifact(
        string memory json,
        string memory methodIdentifier
    ) internal pure returns (string memory) {
        if (!isContain(methodIdentifier, json)) return "";
        // "signature": "methodIdentifier"
        uint end = getPositionStringContained(methodIdentifier, json) - 5;
        uint startPosition = findFirstCharPositionBefore('"', end, json) + 1;

        return slice(startPosition, end, json);
    }

    function _retrieveSelectorFromElement(
        ElementAbi memory elementAbi
    ) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(_retrieveSignatureFromElement(elementAbi))));
    }

    function _retrieveSignatureFromElement(
        ElementAbi memory elementAbi
    ) internal pure returns (string memory) {
        string memory signature = string.concat(elementAbi.name, "(");
        if (elementAbi.inputs.length == 0) return string.concat(signature, ")");
        for (uint i; i < elementAbi.inputs.length - 1; i++) {
            signature = string.concat(signature, elementAbi.inputs[i].type_, ",");
        }

        return string.concat(signature, elementAbi.inputs[elementAbi.inputs.length - 1].type_, ")");
    }

    function _methodIdentifierFromSelector(bytes4 selector) internal pure returns (string memory) {
        return slice(3, 10, Strings.toHexString(uint256(bytes32(selector)), 32));
    }
}
