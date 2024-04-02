// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";
import {OracleConfig} from "./OracleConfig.sol";

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

// Msgport
import "../src/Msgport.sol";

contract ConnectTestScript is Base, OracleConfig {
    using SafeCast for uint256;

    Oracle oracle = Oracle(payable(0xDD8c7c84DaCBbB60F1CfC4f10046245da1E0f33D));
    Relayer relayer =
        Relayer(payable(0xb773319D6Eb7f34b8EAB26Ea5F5ea694E7EF6362));
    ORMPUpgradeablePort ormpUpgradeablePort =
        ORMPUpgradeablePort(0x7e829b7969a5d09A75E0A6F27f306b8C89641C9d);

    // Relayer config
    uint64 gasPerByte = 16;

    function run() public sphinx {
        string[] memory testnets = sphinxConfig.testnets;
        uint256 len = testnets.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 chainId = toChaindId(testnets[i]);
            if (block.chainId != chainId) continue;
            setOracleFee(chainId);
            setRelayerFee(chainId);
            setPortLookup(chainId);
        }
    }

    function setOracleFee(uint256 localChainId) internal {
        string[] memory testnets = sphinxConfig.testnets;
        uint256 len = testnets.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 remoteChainId = toChaindId(testnets[i]);
            if (remoteChainId == localChainId) continue;
            _setOracleFee(localChainId, remoteChainId);
            _setRelayerFee(localChainId, remoteChainId);
        }
    }

    function _setOracleFee(uint256 localChainId, uint256 remoteChainId)
        internal
    {
        if (block.chainId != localChainId) return;
        uint256 fee = getOracleConfig(localChainId, remoteChainId);
        if (fee != oracle.feeOf(remoteChainId)) {
            oracle.setFee(remoteChainId, fee);
        }
    }

    function _setRelayerFee(uint256 localChainId, uint256 remoteChainId)
        internal
    {
        (
            uint128 dstPriceRatio,
            uint128 dstGasPriceInWei,
            uint64 baseGas,
            uint64 gasPerByte
        ) = getRelayerConfig(localChainId, remoteChainId);

        (uint128 ratio, uint128 price) = relayer.priceOf(chainId);
        if (ratio != dstPriceRatio || price != dstGasPriceInWei) {
            relayer.setDstPrice(chainId, dstPriceRatio, dstGasPriceInWei);
        }
        (uint64 b, uint64 g) = relayer.configOf(chainId);
        if (b != baseGas || g != gasPerByte) {
            relayer.setDstConfig(chainId, baseGas, gasPerByte);
        }
    }

    function setPortLookup() internal {
        if (block.chainid == Chains.Sepolia) {
            _setPortLookup(Chains.ArbitrumSepolia);
            _setPortLookup(Chains.TaikoKatla);
            _setPortLookup(Chains.Pangolin);
        }
        if (block.chainid == Chains.ArbitrumSepolia) {
            _setPortLookup(Chains.Sepolia);
            _setPortLookup(Chains.TaikoKatla);
            _setPortLookup(Chains.Pangolin);
        }
        if (block.chainid == Chains.TaikoKatla) {
            _setPortLookup(Chains.Sepolia);
            _setPortLookup(Chains.ArbitrumSepolia);
            _setPortLookup(Chains.Pangolin);
        }
        if (block.chainid == Chains.Pangolin) {
            _setPortLookup(Chains.Sepolia);
            _setPortLookup(Chains.ArbitrumSepolia);
            _setPortLookup(Chains.TaikoKatla);
        }
    }

    function _setPortLookup(uint256 chainId) internal {
        address port = address(ormpUpgradeablePort);
        if (port != ormpUpgradeablePort.fromPortLookup(chainId)) {
            ormpUpgradeablePort.setFromPort(chainId, port);
        }
        if (port != ormpUpgradeablePort.toPortLookup(chainId)) {
            ormpUpgradeablePort.setToPort(chainId, port);
        }
    }
}
