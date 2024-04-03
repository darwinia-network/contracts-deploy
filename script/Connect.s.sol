// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";
import {ScriptTools} from "./ScriptTools.sol";
import {OracleConfig} from "./OracleConfig.sol";
import {RelayerConfig} from "./RelayerConfig.sol";

import {safeconsole} from "forge-std/safeconsole.sol";

// Msgport
import "../src/Msgport.sol";

contract ConnectScript is Base, OracleConfig, RelayerConfig {
    Oracle oracle = Oracle(payable(0xDD8c7c84DaCBbB60F1CfC4f10046245da1E0f33D));
    Relayer relayer = Relayer(payable(0xb773319D6Eb7f34b8EAB26Ea5F5ea694E7EF6362));
    ORMPUpgradeablePort ormpUpgradeablePort = ORMPUpgradeablePort(0x7e829b7969a5d09A75E0A6F27f306b8C89641C9d);

    string[] networks;

    function setUp() public {
        if (block.chainid == 31337) {
            return;
        }
        uint256 local = block.chainid;
        string memory config = ScriptTools.loadConfig(vmSafe.toString(local));
        init(local, config);
    }

    function init(uint256 local, string memory config) public override(Base, OracleConfig, RelayerConfig) {
        Base.init(local, config);
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
            uint256 remoteChainId = getChain(networks[i]).chainId;
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
        if (block.chainid != localChainId) return;
        address port = address(ormpUpgradeablePort);
        if (port != ormpUpgradeablePort.fromPortLookup(remoteChainId)) {
            ormpUpgradeablePort.setFromPort(remoteChainId, port);
        }
        if (port != ormpUpgradeablePort.toPortLookup(remoteChainId)) {
            ormpUpgradeablePort.setToPort(remoteChainId, port);
        }
    }
}
