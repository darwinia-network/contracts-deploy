// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";

// Msgport
import "../src/Msgport.sol";

contract DeployScript is Base {
    bytes32 salt = bytes32(uint256(1));
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
        configOracle();
        deployRelayer();
        configRelayer();
        configORMP();

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

    function configOracle() internal {
        Oracle o = Oracle(payable(oracle));
        address echo = 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec;
        address yalin = 0x178E699c9a6bB2Cd624557Fbd85ed219e6faBa77;
        if (!o.isApproved(dao)) {
            o.setApproved(dao, true);
        }
        if (!o.isApproved(echo)) {
            o.setApproved(echo, true);
        }
        if (!o.isApproved(yalin)) {
            o.setApproved(yalin, true);
        }
        address owner = o.owner();
        if (owner != subapiMultisig) {
            o.changeOwner(subapiMultisig);
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

    function configRelayer() internal {
        Relayer r = Relayer(payable(relayer));
        address echo = 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec;
        address yalin = 0x912D7601569cBc2DF8A7f0aaE50BFd18e8C64d05;
        if (!r.isApproved(dao)) {
            r.setApproved(dao, true);
        }
        if (!r.isApproved(echo)) {
            r.setApproved(echo, true);
        }
        if (!r.isApproved(yalin)) {
            r.setApproved(yalin, true);
        }
    }

    function configORMP() internal {
        (address o, address r) = ORMP(ormp).defaultUC();
        if (o != oracle || r != relayer) {
            ORMP(ormp).setDefaultConfig(oracle, relayer);
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
        string memory uri = "ipfs://bafybeifa7fgeb63rnashodi5k27fxfqfc65hdbyjum5aiqtd2xjeno2dgy";
        string memory u = ORMPUpgradeablePort(ormpUpgradeablePort).uri();
        if (hash(uri) != hash(u)) {
            ORMPUpgradeablePort(ormpUpgradeablePort).setURI(uri);
        }
    }
}
