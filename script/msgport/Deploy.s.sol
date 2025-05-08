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
    bytes32 salt2 = bytes32(uint256(2));

    address[] signers = [
        0x1989D93Ec04037cA64e2af7e48FF5C8Fc2cEA7B8, // xavier
        0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85, // guantong
        0xB9a0CaDD13C5d534b034d878b2fcA9E5a6e1e3A4, // echo
        0xc1A3FEE4132e9285f41F5389570fD9Fbbcb10a1D, // yalin
        0xFa5727bE643dba6599fC7F812fE60dA3264A8205  // nada
    ];
    uint64 quorum = 3;

    function _run() internal virtual {
        deployMsgport();
        // deployXAccount();
    }

    function deployXAccount() public {
        deployPortRegistry();
        deployMultiPort();
        deploySafeMsgportModule();
        deployXAccountFactory();

        configXAccount();
    }

    function configXAccount() public {
        configMultiPort();
    }

    function configMultiPort() internal {
        MultiPort multiPort = MultiPort(MULTIPORT());
        address ormpPort = ORMPUPORT();
        if (!multiPort.isTrustedPort(ormpPort)) {
            multiPort.addTrustedPort(ormpPort);
        }
    }

    function REGISTRY() public returns (address) {
        bytes memory logicByteCode = type(PortRegistry).creationCode;
        address logic = computeAddress(salt, hash(logicByteCode));
        bytes memory proxyByteCode = type(PortRegistryProxy).creationCode;
        bytes memory initData = abi.encodeWithSelector(PortRegistry.initialize.selector, DAO());
        bytes memory initCode = bytes.concat(proxyByteCode, abi.encode(address(logic), initData));
        return computeAddress(salt, hash(initCode));
    }

    function MODULE() public view returns (address) {
        bytes memory byteCode = type(SafeMsgportModule).creationCode;
        return computeAddress(salt, hash(byteCode));
    }

    function MULTIPORT() public returns (address) {
        bytes memory byteCode = type(MultiPort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), 1, "Multi"));
        return computeAddress(salt, hash(initCode));
    }

    function XACCOUNTFACTORY() public returns (address) {
        return computeCreate3Address(salt);
    }

    function deployPortRegistry() internal {
        bytes memory logicByteCode = type(PortRegistry).creationCode;
        address logic = computeAddress(salt, hash(logicByteCode));
        if (logic.code.length == 0) _deploy2(salt, logicByteCode);
        bytes memory proxyByteCode = type(PortRegistryProxy).creationCode;
        bytes memory initData = abi.encodeWithSelector(PortRegistry.initialize.selector, DAO());
        bytes memory initCode = bytes.concat(proxyByteCode, abi.encode(address(logic), initData));
        address proxy = computeAddress(salt, hash(initCode));
        if (proxy.code.length == 0) _deploy2(salt, initCode);
    }

    function deployMultiPort() internal {
        bytes memory byteCode = type(MultiPort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(DAO(), 1, "Multi"));
        address multiPort = computeAddress(salt, hash(initCode));
        if (multiPort.code.length == 0) _deploy2(salt, initCode);
    }

    function deploySafeMsgportModule() internal {
        bytes memory byteCode = type(SafeMsgportModule).creationCode;
        address module = computeAddress(salt, hash(byteCode));
        if (module.code.length == 0) _deploy2(salt, byteCode);
    }

    function deployXAccountFactory() internal {
        (address safeFactory, address safeSingleton, address safeFallbackHandler) = readSafeDeployment();
        bytes memory byteCode = type(XAccountFactory).creationCode;
        bytes memory initCode = bytes.concat(
            byteCode,
            abi.encode(DAO(), MODULE(), safeFactory, safeSingleton, safeFallbackHandler, REGISTRY(), "xAccountFactory")
        );
        address factory = computeCreate3Address(salt);
        if (factory.code.length == 0) _deploy3(salt, initCode);
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
		return computeAddress(salt2, hash(initCode));
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
        if (ORACLE().code.length == 0) _deploy2(salt2, initCode);
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
        address yalinOld = 0x178E699c9a6bB2Cd624557Fbd85ed219e6faBa77;
        address yalinNew = 0xc1A3FEE4132e9285f41F5389570fD9Fbbcb10a1D;
        if (!o.isApproved(dao)) {
            o.setApproved(dao, true);
        }
        if (!o.isApproved(echo)) {
            o.setApproved(echo, true);
        }
        if (o.isApproved(yalinOld)) {
            o.setApproved(yalinOld, false);
        }
        if (!o.isApproved(yalinNew)) {
            o.setApproved(yalinNew, true);
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
        address yalinOld = 0x912D7601569cBc2DF8A7f0aaE50BFd18e8C64d05;
        address yalinNew = 0x40C168503B9758540E18A79907F3Fd8678c13f03;
        address guantong = 0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85;
        if (!r.isApproved(dao)) {
            r.setApproved(dao, true);
        }
        if (!r.isApproved(echo)) {
            r.setApproved(echo, true);
        }
        if (r.isApproved(yalinOld)) {
            r.setApproved(yalinOld, false);
        }
        if (!r.isApproved(yalinNew)) {
            r.setApproved(yalinNew, true);
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
