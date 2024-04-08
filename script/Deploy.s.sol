// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";

// Msgport
import "../src/Msgport.sol";

contract DeployScript is Base {
    bytes32 salt = bytes32(uint256(10));

    address[] signers = [
        0x178E699c9a6bB2Cd624557Fbd85ed219e6faBa77,
        0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85,
        0xA4bE619E8C0E3889f5fA28bb0393A4862Cad35ad,
        0xB9a0CaDD13C5d534b034d878b2fcA9E5a6e1e3A4,
        0xFa5727bE643dba6599fC7F812fE60dA3264A8205
    ];
    uint64 quorum = 3;

    function run() public sphinx {
        // Deploy SubAPIMultiSig
        deploySubAPIMultiSig();

        // Deploy ORMP
        deployORMP();
        deployOracle();
        deployRelayer();

        // Deploy ORMPUpgradeablePort
        deployORMPUPort();

        config();
    }

    function config() public {
        configOracle();
        configRelayer();
        configORMP();
        configORMPUPort();
    }

    function DAO() public returns (address) {
        return safeAddress();
    }

    function SUBAPIMULTISIG() public view returns (address) {
        bytes memory byteCode = type(SubAPIMultiSig).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(signers, quorum));
        return computeAddress(salt, hash(initCode));
    }

    function ORMPAddr() public returns (address) {
        bytes memory byteCode = type(ORMP).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO()));
        return computeAddress(salt, hash(initCode));
    }

    function ORACLE() public returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr()));
        return computeAddress(salt, hash(initCode));
    }

    function RELAYER() public returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr()));
        return computeAddress(salt, hash(initCode));
    }

    function ORMPUPORT() public returns (address) {
        string memory name = "ORMP-U";
        bytes memory byteCode = type(ORMPUpgradeablePort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr(), name));
        return computeAddress(salt, hash(initCode));
    }

    function deploySubAPIMultiSig() internal {
        bytes memory byteCode = type(SubAPIMultiSig).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(signers, quorum));
        _deploy2(salt, initCode);
    }

    function deployORMP() internal {
        bytes memory byteCode = type(ORMP).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO()));
        _deploy2(salt, initCode);
    }

    function deployOracle() internal {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr()));
        _deploy2(salt, initCode);
    }

    function deployRelayer() internal {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr()));
        _deploy2(salt, initCode);
    }

    function deployORMPUPort() internal {
        string memory name = "ORMP-U";
        bytes memory byteCode = type(ORMPUpgradeablePort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr(), name));
        _deploy2(salt, initCode);
    }

    function configOracle() internal {
        Oracle o = Oracle(payable(ORACLE()));
        address echo = 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec;
        address yalin = 0x178E699c9a6bB2Cd624557Fbd85ed219e6faBa77;
        o.setApproved(DAO(), true);
        o.setApproved(echo, true);
        o.setApproved(yalin, true);
        o.changeOwner(SUBAPIMULTISIG());
    }

    function configRelayer() internal {
        Relayer r = Relayer(payable(RELAYER()));
        address echo = 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec;
        address yalin = 0x912D7601569cBc2DF8A7f0aaE50BFd18e8C64d05;
        r.setApproved(DAO(), true);
        r.setApproved(echo, true);
        r.setApproved(yalin, true);
    }

    function configORMP() internal {
        ORMP(ORMPAddr()).setDefaultConfig(ORACLE(), RELAYER());
    }

    function configORMPUPort() internal {
        string memory uri = "ipfs://bafybeifa7fgeb63rnashodi5k27fxfqfc65hdbyjum5aiqtd2xjeno2dgy";
        ORMPUpgradeablePort(ORMPUPORT()).setURI(uri);
    }
}
