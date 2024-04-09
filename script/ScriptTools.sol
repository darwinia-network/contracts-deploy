// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {VmSafe} from "forge-std/Vm.sol";
import {stdToml} from "forge-std/StdToml.sol";

/// @title Script Tools
/// @dev Contains opinionated tools used in scripts.
library ScriptTools {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    string internal constant DEFAULT_DELIMITER = ",";
    string internal constant DELIMITER_OVERRIDE = "DSSTEST_ARRAY_DELIMITER";

    function readInput(string memory name) internal view returns (string memory) {
        string memory root = vm.projectRoot();
        return readInput(root, name);
    }

    function readInput(string memory root, string memory name) internal view returns (string memory) {
        return vm.readFile(string.concat(root, "/script/input/", name, ".toml"));
    }

    function loadConfig(string memory name) internal view returns (string memory config) {
        config = vm.envOr("FOUNDRY_SCRIPT_CONFIG_TEXT", string(""));
        if (eq(config, "")) {
            config = readInput(vm.envOr("FOUNDRY_SCRIPT_CONFIG", name));
        }
    }

    function loadConfig() internal view returns (string memory config) {
        config = vm.envOr("FOUNDRY_SCRIPT_CONFIG_TEXT", string(""));
        if (eq(config, "")) {
            config = readInput(vm.envString("FOUNDRY_SCRIPT_CONFIG"));
        }
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    // Read config variable, but allow for an environment variable override

    function readUint(string memory json, string memory key, string memory envKey) internal view returns (uint256) {
        return vm.envOr(envKey, stdToml.readUint(json, key));
    }

    function readUintArray(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (uint256[] memory)
    {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdToml.readUintArray(json, key));
    }

    function readInt(string memory json, string memory key, string memory envKey) internal view returns (int256) {
        return vm.envOr(envKey, stdToml.readInt(json, key));
    }

    function readIntArray(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (int256[] memory)
    {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdToml.readIntArray(json, key));
    }

    function readBytes32(string memory json, string memory key, string memory envKey) internal view returns (bytes32) {
        return vm.envOr(envKey, stdToml.readBytes32(json, key));
    }

    function readBytes32Array(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (bytes32[] memory)
    {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdToml.readBytes32Array(json, key));
    }

    function readString(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (string memory)
    {
        return vm.envOr(envKey, stdToml.readString(json, key));
    }

    function readStringArray(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (string[] memory)
    {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdToml.readStringArray(json, key));
    }

    function readAddress(string memory json, string memory key, string memory envKey) internal view returns (address) {
        return vm.envOr(envKey, stdToml.readAddress(json, key));
    }

    function readAddressArray(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (address[] memory)
    {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdToml.readAddressArray(json, key));
    }

    function readBool(string memory json, string memory key, string memory envKey) internal view returns (bool) {
        return vm.envOr(envKey, stdToml.readBool(json, key));
    }

    function readBoolArray(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (bool[] memory)
    {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdToml.readBoolArray(json, key));
    }

    function readBytes(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (bytes memory)
    {
        return vm.envOr(envKey, stdToml.readBytes(json, key));
    }

    function readBytesArray(string memory json, string memory key, string memory envKey)
        internal
        view
        returns (bytes[] memory)
    {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdToml.readBytesArray(json, key));
    }
}
