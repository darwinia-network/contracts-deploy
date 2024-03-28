// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";

// Msgport
import "../src/Msgport.sol";

contract DeployScript is Base {
    bytes32 salt = bytes32(0);
    address[] signers = [
        0x178E699c9a6bB2Cd624557Fbd85ed219e6faBa77,
        0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85,
        0xA4bE619E8C0E3889f5fA28bb0393A4862Cad35ad,
        0xB9a0CaDD13C5d534b034d878b2fcA9E5a6e1e3A4,
        0xFa5727bE643dba6599fC7F812fE60dA3264A8205
    ];
    uint64 quorum = 3;

    address dao;
    address subapiMultisig;
    address ormp;
    address oracle;
    address relayer;
    address ormpUpgradeablePort;

    function run() public sphinx {
        dao = safeAddress();

        // Deploy SubAPIMultiSig
        deploySubAPIMultiSig();

        // Deploy ORMP
        deployORMP();
        deployOracle();
        deployRelayer();

        // Deploy ORMPUpgradeablePort
        deployORMPUPort();
    }

    function deploySubAPIMultiSig() internal {
        bytes memory byteCode = type(SubAPIMultiSig).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(signers, quorum));
        subapiMultisig = computeAddress(salt, hash(initCode));
        if (subapiMultisig.code.length == 0) {
            subapiMultisig = _deploy2(salt, initCode);
        }
    }

    function deployORMP() internal {
        bytes memory byteCode = type(ORMP).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(dao));
        ormp = computeAddress(salt, hash(initCode));
        if (ormp.code.length == 0) {
            ormp = _deploy2(salt, initCode);
        }
    }

    function deployOracle() internal {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(dao));
        oracle = computeAddress(salt, hash(initCode));
        if (oracle.code.length == 0) {
            oracle = _deploy2(salt, initCode);
        }
    }

    function deployRelayer() internal {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(dao, ormp));
        relayer = computeAddress(salt, hash(initCode));
        if (relayer.code.length == 0) {
            relayer = _deploy2(salt, initCode);
        }
    }

    function deployORMPUPort() internal {
        string memory name = "ORMP-U";
        bytes memory byteCode = type(ORMPUpgradeablePort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(dao, ormp, name));
        ormpUpgradeablePort = computeAddress(salt, hash(initCode));
        if (ormpUpgradeablePort.code.length == 0) {
            ormpUpgradeablePort = _deploy2(salt, initCode);
        }
    }
}
