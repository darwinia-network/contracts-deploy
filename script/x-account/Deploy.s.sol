// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";
import {TomlTools} from "../common/TomlTools.sol";
import {stdJson} from "forge-std/StdJson.sol";

// Msgport
import "../../src/XAccount.sol";

contract DeployScript is Base {
    using stdJson for string;

    bytes32 salt = bytes32(uint256(1));

    address ORMPUPORT = 0x2cd1867Fb8016f93710B6386f7f9F1D540A60812;

    function run() public sphinx {
        deployXAccount();
    }

    function deployXAccount() public {
        deploySafeMsgportModule();
        deployXAccountFactory();
        deployXAccountUIFactory();
    }

    function MODULE() public view returns (address) {
        bytes memory byteCode = type(SafeMsgportModule).creationCode;
        return computeAddress(salt, hash(byteCode));
    }

    function FACTORY() public view returns (address) {
        bytes memory byteCode = type(XAccountFactory).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(MODULE()));
        return computeAddress(salt, hash(initCode));
    }

    function UIFACTORY() public view returns (address) {
        bytes memory byteCode = type(XAccountUIFactory).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(FACTORY()));
        return computeAddress(salt, hash(initCode));
    }

    function deploySafeMsgportModule() internal {
        bytes memory byteCode = type(SafeMsgportModule).creationCode;
        address module = computeAddress(salt, hash(byteCode));
        if (module.code.length == 0) _deploy2(salt, byteCode);
    }

    function deployXAccountFactory() internal {
        bytes memory byteCode = type(XAccountFactory).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(MODULE()));
        address factory = computeAddress(salt, hash(initCode));
        if (factory.code.length == 0) _deploy2(salt, initCode);
    }

    function deployXAccountUIFactory() internal {
        bytes memory byteCode = type(XAccountUIFactory).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(FACTORY()));
        address uifactory = computeAddress(salt, hash(initCode));
        if (uifactory.code.length == 0) _deploy2(salt, initCode);
    }

    function DAO() public returns (address) {
        return safeAddress();
    }
}
