// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";
import {Chains} from "./Chains.sol";

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

// Msgport
import "../src/Msgport.sol";

contract ConnectTestScript is Base {
    using Chains for uint256;
    using SafeCast for uint256;

    Oracle oracle = Oracle(payable(0x1502ba96644a3b660Ee9cdC214f9B739Ee04b7F1));
    Relayer relayer = Relayer(payable(0x5326853463Eb23e738Fb9CbFEb6d7361cb4E8AA5));
    ORMPUpgradeablePort ormpUpgradeablePort = ORMPUpgradeablePort(0xf7472Fc23788946FB89bBF0666F0A9D79A69EcB4);

    // Oracle config
    uint256 priceMultiplier = 1e9;
    uint256 ethPrice = 3600 * priceMultiplier;
    uint256 ringPrice = priceMultiplier / 200;
    uint256 gasPrice = 40 gwei;

    // Relayer config
    uint64 gasPerByte = 16;

    function run() public sphinx {
        setOracleFee();
        setRelayerFee();
        setPortLookup();
    }

    function setOracleFee() internal {
        setSepoliaOracleFee();
        setArbitrumSepoliaOracleFee();
        setTaikoKatlaOracleFee();
        setPangolinOracleFee();
    }

    function setRelayerFee() internal {
        setSepoliaRelayerFee();
        setArbitrumSepoliaRelayerFee();
        setTaikoKatlaRelayerFee();
        setPangolinRelayerFee();
    }

    function setSepoliaOracleFee() internal {
        uint256 gas = 110000;
        uint256 usd = gas * gasPrice * ethPrice;
        if (block.chainid == Chains.Sepolia) {
            return;
        }
        if (block.chainid == Chains.ArbitrumSepolia || block.chainid == Chains.TaikoKatla) {
            _setOracleFee(Chains.Sepolia, gas * gasPrice);
        }
        if (block.chainid == Chains.Pangolin) {
            _setOracleFee(Chains.Sepolia, usd / ringPrice);
        }
    }

    function setArbitrumSepoliaOracleFee() internal {
        uint256 gas = 110000 / 100;
        uint256 usd = gas * gasPrice * ethPrice;
        if (block.chainid == Chains.ArbitrumSepolia) {
            return;
        }
        if (block.chainid == Chains.Sepolia || block.chainid == Chains.ArbitrumSepolia) {
            _setOracleFee(Chains.ArbitrumSepolia, gas * gasPrice);
        }
        if (block.chainid == Chains.Pangolin) {
            _setOracleFee(Chains.ArbitrumSepolia, usd / ringPrice);
        }
    }

    function setPangolinOracleFee() internal {
        uint256 gas = 110000;
        uint256 usd = gas * gasPrice * ringPrice;
        if (block.chainid == Chains.Pangolin) {
            return;
        }
        if (
            block.chainid == Chains.Sepolia || block.chainid == Chains.ArbitrumSepolia
                || block.chainid == Chains.TaikoKatla
        ) {
            _setOracleFee(Chains.Pangolin, usd / ethPrice);
        }
    }

    function setTaikoKatlaOracleFee() internal {
        uint256 gas = 110000 / 100;
        uint256 usd = gas * gasPrice * ethPrice;
        if (block.chainid == Chains.TaikoKatla) {
            return;
        }
        if (block.chainid == Chains.Sepolia || block.chainid == Chains.ArbitrumSepolia) {
            _setOracleFee(Chains.TaikoKatla, gas * gasPrice);
        }
        if (block.chainid == Chains.Pangolin) {
            _setOracleFee(Chains.TaikoKatla, usd / ringPrice);
        }
    }

    function _setOracleFee(uint256 chainId, uint256 fee) internal {
        if (fee != oracle.feeOf(chainId)) {
            oracle.setFee(chainId, fee);
        }
    }

    function setSepoliaRelayerFee() internal {
        uint64 baseGas = 120000;
        uint128 dstGasPriceInWei = 40 gwei;
        if (block.chainid == Chains.Sepolia) {
            return;
        }
        if (block.chainid == Chains.ArbitrumSepolia || block.chainid == Chains.TaikoKatla) {
            uint128 dstPriceRatio = 1e10;
            _setRelayerFee(Chains.Sepolia, dstPriceRatio, dstGasPriceInWei, baseGas);
        }
        if (block.chainid == Chains.Pangolin) {
            uint256 dstPriceRatio = ethPrice * 1e10 / ringPrice;
            _setRelayerFee(Chains.Sepolia, dstPriceRatio.toUint128(), dstGasPriceInWei, baseGas);
        }
    }

    function setArbitrumSepoliaRelayerFee() internal {
        uint64 baseGas = 1;
        uint128 dstGasPriceInWei = 110000000;
        if (block.chainid == Chains.ArbitrumSepolia) {
            return;
        }
        if (block.chainid == Chains.Sepolia || block.chainid == Chains.TaikoKatla) {
            uint128 dstPriceRatio = 1e10;
            _setRelayerFee(Chains.Sepolia, dstPriceRatio, dstGasPriceInWei, baseGas);
        }
        if (block.chainid == Chains.Pangolin) {
            uint256 dstPriceRatio = ethPrice * 1e10 / ringPrice;
            _setRelayerFee(Chains.Sepolia, dstPriceRatio.toUint128(), dstGasPriceInWei, baseGas);
        }
    }

    function setTaikoKatlaRelayerFee() internal {
        uint64 baseGas = 200000;
        // TODO: check
        uint128 dstGasPriceInWei = 9;
        if (block.chainid == Chains.TaikoKatla) {
            return;
        }
        if (block.chainid == Chains.Sepolia || block.chainid == Chains.ArbitrumSepolia) {
            uint128 dstPriceRatio = 1e10;
            _setRelayerFee(Chains.Sepolia, dstPriceRatio, dstGasPriceInWei, baseGas);
        }
        if (block.chainid == Chains.Pangolin) {
            uint256 dstPriceRatio = ethPrice * 1e10 / ringPrice;
            _setRelayerFee(Chains.Sepolia, dstPriceRatio.toUint128(), dstGasPriceInWei, baseGas);
        }
    }

    function setPangolinRelayerFee() internal {
        uint64 baseGas = 200000;
        uint128 dstGasPriceInWei = 180000000000;
        if (block.chainid == Chains.Pangolin) {
            return;
        }
        if (
            block.chainid == Chains.Sepolia || block.chainid == Chains.ArbitrumSepolia
                || block.chainid == Chains.TaikoKatla
        ) {
            uint256 dstPriceRatio = ringPrice * 1e10 / ethPrice;
            _setRelayerFee(Chains.Sepolia, dstPriceRatio.toUint128(), dstGasPriceInWei, baseGas);
        }
    }

    function _setRelayerFee(uint256 chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei, uint64 baseGas)
        internal
    {
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
