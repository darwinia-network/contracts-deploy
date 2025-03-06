// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";
import {TomlTools} from "../common/TomlTools.sol";
import {OracleConfig} from "./OracleConfig.sol";
import {RelayerConfig} from "./RelayerConfig.sol";

import {safeconsole} from "forge-std/safeconsole.sol";

import "../../src/Msgport.sol";

contract UpdateFeeScript is Base, OracleConfig, RelayerConfig {
    Oracle oracle = Oracle(payable(0xBE01B76AB454aE2497aE43168b1F70C92Ac1C726));
    Relayer relayer = Relayer(payable(0x114890eB7386F94eae410186F20968bFAf66142a));
    string[] networks;

    function setUp() public {
        if (block.chainid == 31337) {
            return;
        }
        uint256 local = block.chainid;
        string memory config = TomlTools.loadConfig(vmSafe.toString(local));
        init(local, config);
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
        update(block.chainid);
	}

	function update(uint256 localChainId) internal {
        uint256 len = networks.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 remoteChainId = getChainId(networks[i]);
            if (remoteChainId == localChainId) continue;
            if (isSupported[remoteChainId]) {
                _setOracleFee(localChainId, remoteChainId);
                _setRelayerFee(localChainId, remoteChainId);
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
}
