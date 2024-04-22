// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";
import {TomlTools} from "./TomlTools.sol";
import {OracleConfig} from "./OracleConfig.sol";
import {RelayerConfig} from "./RelayerConfig.sol";

import {safeconsole} from "forge-std/safeconsole.sol";

// Msgport
import "../src/Msgport.sol";
import "./Deploy.s.sol";
import {PortRegistry} from "@darwinia-msgport/src/PortRegistry.sol";

interface III {
    function fromPortLookup(uint256 chainId) external returns (address);
    function toPortLookup(uint256 chainId) external returns (address);
    function setFromPort(uint256 chainId, address port) external;
    function setToPort(uint256 chainId, address port) external;
}

contract ConnectScript is Base, OracleConfig, RelayerConfig {
    Oracle oracle;
    Relayer relayer;
    address ormpUpgradeablePort;
    address multiPort;
    address registry;

    string[] networks;

    DeployScript deploy;

    function setUp() public {
        if (block.chainid == 31337) {
            return;
        }
        uint256 local = block.chainid;
        string memory config = TomlTools.loadConfig(vmSafe.toString(local));
        init(local, config);
        deploy = new DeployScript();
        oracle = Oracle(payable(deploy.ORACLE()));
        relayer = Relayer(payable(deploy.RELAYER()));
        ormpUpgradeablePort = deploy.ORMPUPORT();
        multiPort = deploy.MULTIPORT();
        registry = deploy.REGISTRY();
    }

    function init(uint256 local, string memory config) public override(OracleConfig, RelayerConfig) {
        OracleConfig.init(local, config);
        RelayerConfig.init(local, config);
    }

    function run() public sphinx {
        bool isTest = vmSafe.envOr("IS_TEST", true);
        if (isTest) {
            networks = sphinxConfig.testnets;
        } else {
            networks = sphinxConfig.mainnets;
        }
        connect(block.chainid);
    }

    function connect(uint256 localChainId) internal {
        uint256 len = networks.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 remoteChainId = getChainId(networks[i]);
            _setPortRegistry(remoteChainId);
            if (remoteChainId == localChainId) continue;
            _setOracleFee(localChainId, remoteChainId);
            _setRelayerFee(localChainId, remoteChainId);
            _setPortLookup(localChainId, remoteChainId);
        }
    }

    function _setOracleFee(uint256 localChainId, uint256 remoteChainId) internal {
        if (block.chainid != localChainId) return;
        uint256 fee = getOracleConfig(localChainId, remoteChainId);
        if (fee != oracle.feeOf(remoteChainId)) {
            oracle.setFee(remoteChainId, fee);
        }
    }

    function _setRelayerFee(uint256 localChainId, uint256 remoteChainId) internal {
        if (block.chainid != localChainId) return;
        Config memory c = getRelayerConfig(localChainId, remoteChainId);

        (uint128 ratio, uint128 price) = relayer.priceOf(remoteChainId);
        if (ratio != c.dstPriceRatio || price != c.dstGasPriceInWei) {
            relayer.setDstPrice(remoteChainId, c.dstPriceRatio, c.dstGasPriceInWei);
        }
        (uint64 b, uint64 g) = relayer.configOf(remoteChainId);
        if (b != c.baseGas || g != c.gasPerByte) {
            relayer.setDstConfig(remoteChainId, c.baseGas, c.gasPerByte);
        }
    }

    function _setPortLookup(uint256 localChainId, uint256 remoteChainId) internal {
        _setPortLookup(ormpUpgradeablePort, localChainId, remoteChainId);
        _setPortLookup(multiPort, localChainId, remoteChainId);
    }

    function _setPortLookup(address port, uint256 localChainId, uint256 remoteChainId) internal {
        if (block.chainid != localChainId) return;
        if (port != III(port).fromPortLookup(remoteChainId)) {
            III(port).setFromPort(remoteChainId, port);
        }
        if (port != III(port).toPortLookup(remoteChainId)) {
            III(port).setToPort(remoteChainId, port);
        }
    }

    function _setPortRegistry(uint256 chainId) internal {
        _setPortRegistry(ormpUpgradeablePort, chainId, "ORMP-U");
        _setPortRegistry(multiPort, chainId, "Multi");
    }

    function _setPortRegistry(address port, uint256 chainId, string memory name) internal {
        if (port != PortRegistry(registry).get(chainId, name)) {
            PortRegistry(registry).set(chainId, name, port);
        }
        require(PortRegistry(registry).get(chainId, name) == port);
    }
}
