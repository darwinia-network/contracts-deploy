// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";
import {TomlTools} from "../common/TomlTools.sol";
import {OracleConfig} from "../ormp/OracleConfig.sol";
import {RelayerConfig} from "../ormp/RelayerConfig.sol";

import {safeconsole} from "forge-std/safeconsole.sol";

// Msgport
import "../../src/Msgport.sol";
import "./Deploy.s.sol";
import {PortRegistry} from "@darwinia-msgport/src/PortRegistry.sol";

interface III {
    function peerOf(uint256 chainId) external view returns (address);
    function setPeer(uint256 chainId, address peer) external;
}

contract ConnectScript is Base, OracleConfig, RelayerConfig {
    Oracle oracle;
    Relayer relayer;
    address ormpUpgradeablePort;
    address multiPort;
    address xAccountFactory;
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
        xAccountFactory = deploy.XACCOUNTFACTORY();
    }

    function init(uint256 local, string memory config) public override(OracleConfig, RelayerConfig) {
        OracleConfig.init(local, config);
        RelayerConfig.init(local, config);
    }

    function run() public sphinx {
        bool IS_PROD = vmSafe.envOr("IS_PROD", true);
        if (IS_PROD) {
            networks = sphinxConfig.mainnets;
        } else {
            networks = sphinxConfig.testnets;
        }
        connect(block.chainid);
        // darwinia connect to tron
        if (IS_PROD) {
            if (block.chainid == 46) {
                if (
                    0x3Bc5362EC3a3DBc07292aEd4ef18Be18De02DA3a
                        != III(0x2cd1867Fb8016f93710B6386f7f9F1D540A60812).peerOf(728126428)
                ) {
                    III(0x2cd1867Fb8016f93710B6386f7f9F1D540A60812).setPeer(
                        728126428, 0x3Bc5362EC3a3DBc07292aEd4ef18Be18De02DA3a
                    );
                }
            }
        } else {
            if (block.chainid == 701 || block.chainid == 11155111) {
                if (
                    0xb5F017129950C21d870019f6066C42E25acDAAe3
                        != III(0x2cd1867Fb8016f93710B6386f7f9F1D540A60812).peerOf(2494104990)
                ) {
                    III(0x2cd1867Fb8016f93710B6386f7f9F1D540A60812).setPeer(
                        2494104990, 0xb5F017129950C21d870019f6066C42E25acDAAe3
                    );
                }
            }
        }
    }

    function connect(uint256 localChainId) internal {
        uint256 len = networks.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 remoteChainId = getChainId(networks[i]);
            _setPortRegistry(remoteChainId);
            if (remoteChainId == localChainId) continue;
            if (isSupported[remoteChainId]) {
                _setOracleFee(localChainId, remoteChainId);
                _setRelayerFee(localChainId, remoteChainId);
                _setPortLookup(localChainId, remoteChainId);
            }
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
        if (port != III(port).peerOf(remoteChainId)) {
            III(port).setPeer(remoteChainId, port);
        }
    }

    function _setPortRegistry(uint256 chainId) internal {
        _setPortRegistry(ormpUpgradeablePort, chainId, "ORMP-U");
        _setPortRegistry(multiPort, chainId, "Multi");
        _setPortRegistry(xAccountFactory, chainId, "xAccountFactory");
    }

    function _setPortRegistry(address port, uint256 chainId, string memory name) internal {
        if (port != PortRegistry(registry).get(chainId, name)) {
            PortRegistry(registry).set(chainId, name, port);
        }
        require(PortRegistry(registry).get(chainId, name) == port);
    }
}
