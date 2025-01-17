// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";
import {TomlTools} from "../common/TomlTools.sol";
import {stdJson} from "forge-std/StdJson.sol";

// Msgport
import "../../src/Msgport.sol";

contract DeployScript is Base {
    using stdJson for string;

    bytes32 salt = bytes32(uint256(1));

    address[] signers = [
        0x178E699c9a6bB2Cd624557Fbd85ed219e6faBa77,
        0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85,
        0xA4bE619E8C0E3889f5fA28bb0393A4862Cad35ad,
        0xB9a0CaDD13C5d534b034d878b2fcA9E5a6e1e3A4,
        0xFa5727bE643dba6599fC7F812fE60dA3264A8205
    ];
    uint64 quorum = 3;

    function _run() internal virtual {
        deployMsgport();
        // deployMultiPort();
    }

    function deployMultiPort() public {
        _deployMultiPort();
        _configMultiPort();
    }

    function _configMultiPort() internal {
        MultiPort multiPort = MultiPort(MULTIPORT());
        address ormpPort = ORMPUPORT();
        if (!multiPort.isTrustedPort(ormpPort)) {
            multiPort.addTrustedPort(ormpPort);
        }
    }

    function MULTIPORT() public returns (address) {
        bytes memory byteCode = type(MultiPort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), 1, "Multi"));
        return computeAddress(salt, hash(initCode));
    }

    function _deployMultiPort() internal {
        bytes memory byteCode = type(MultiPort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), 1, "Multi"));
        address multiPort = computeAddress(salt, hash(initCode));
        if (multiPort.code.length == 0) _deploy2(salt, initCode);
    }

    function deployMsgport() public {
        // Deploy SubAPIMultiSig
        deploySubAPIMultiSig();

        // Deploy ORMP
        deployORMP();
        deployOracle();
        deployRelayer();

        // Deploy ORMPUpgradeablePort
        deployORMPUPort();

        configMsgport();
    }

    function configMsgport() public {
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
        if (SUBAPIMULTISIG().code.length == 0) _deploy2(salt, initCode);
    }

    function deployORMP() internal {
        bytes memory byteCode = type(ORMP).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO()));
        if (ORMPAddr().code.length == 0) _deploy2(salt, initCode);
    }

    function deployOracle() internal {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr()));
        if (ORACLE().code.length == 0) _deploy2(salt, initCode);
    }

    function deployRelayer() internal {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr()));
        if (RELAYER().code.length == 0) _deploy2(salt, initCode);
    }

    function deployORMPUPort() internal {
        string memory name = "ORMP-U";
        bytes memory byteCode = type(ORMPUpgradeablePort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), ORMPAddr(), name));
        if (ORMPUPORT().code.length == 0) _deploy2(salt, initCode);
    }

    function configOracle() internal {
        Oracle o = Oracle(payable(ORACLE()));
        address dao = DAO();
        address subapiMultisig = SUBAPIMULTISIG();
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

    function configRelayer() internal {
        Relayer r = Relayer(payable(RELAYER()));
        address dao = DAO();
        address echo = 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec;
        address yalin = 0x912D7601569cBc2DF8A7f0aaE50BFd18e8C64d05;
        address guantong = 0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85;
        if (!r.isApproved(dao)) {
            r.setApproved(dao, true);
        }
        if (!r.isApproved(echo)) {
            r.setApproved(echo, true);
        }
        if (!r.isApproved(yalin)) {
            r.setApproved(yalin, true);
        }
        if (!r.isApproved(guantong)) {
            r.setApproved(guantong, true);
        }
    }

    function configORMP() internal {
        address ormp = ORMPAddr();
        address oracle = ORACLE();
        address relayer = RELAYER();
        (address o, address r) = ORMP(ormp).defaultUC();
        if (o != oracle || r != relayer) {
            ORMP(ormp).setDefaultConfig(oracle, relayer);
        }
    }

    function configORMPUPort() internal {
        string memory uri = "ipfs://bafybeidmfr357ouhgr3zwupkl66unzicf6kkies4bkq6fv5lmz5rtvrk5e";
        address ormpuport = ORMPUPORT();
        if (!TomlTools.eq(uri, ORMPUpgradeablePort(ormpuport).uri())) {
            ORMPUpgradeablePort(ormpuport).setURI(uri);
        }
    }

    function readSafeDeployment()
        internal
        view
        returns (address proxyFactory, address gnosisSafe, address fallbackHandler)
    {
        uint256 chainId = block.chainid;
        string memory root = vm.projectRoot();
        string memory safeFolder = string(abi.encodePacked("/lib/safe-deployments/src/assets/v1.3.0/"));
        string memory proxyFactoryFile = vm.readFile(string(abi.encodePacked(root, safeFolder, "proxy_factory.json")));
        proxyFactory =
            proxyFactoryFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));
        string memory gasisSafeJson;
        if (isL2(chainId)) {
            gasisSafeJson = "gnosis_safe_l2.json";
        } else {
            gasisSafeJson = "gnosis_safe.json";
        }

        string memory fallbackHandlerFile =
            vm.readFile(string(abi.encodePacked(root, safeFolder, "compatibility_fallback_handler.json")));
        fallbackHandler =
            fallbackHandlerFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));

        string memory gnosisSageFile = vm.readFile(string(abi.encodePacked(root, safeFolder, gasisSafeJson)));
        gnosisSafe = gnosisSageFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));
    }
}
