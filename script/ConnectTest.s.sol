// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "./Base.sol";

// Msgport
import "../src/Msgport.sol";

contract ConnectTestScript is Base {
    Oracle oracle = Oracle(payable(0x1502ba96644a3b660Ee9cdC214f9B739Ee04b7F1));
    address relayer = 0x5326853463Eb23e738Fb9CbFEb6d7361cb4E8AA5;
    address ormpUpgradeablePort = 0xf7472Fc23788946FB89bBF0666F0A9D79A69EcB4;

    uint256 priceMultiplier = 1e9;
    uint256 ethPrice = 3600 * priceMultiplier;
    uint256 ringPrice = priceMultiplier / 200 ;
    uint256 gasPrice = 40 gwei;

    function run() public sphinx {
        setOracleFee();
        // setRelayerFee();
    }

    function setOracleFee() internal {
        setSepoliaOracleFee();
        setArbitrumSepoliaOracleFee();
        setPangolinOracleFee();
        setTaikoKatlaOracleFee();
    }

    function setSepoliaOracleFee() internal {
        uint256 sepoliaChainId = 11155111;
        uint256 gas = 110000;
        uint256 usd = gas * gasPrice * ethPrice / 1e18;
        if (block.chainid == sepoliaChainId) {
            return;
        }
        // arbitrum-sepolia, taiko-katla
        if (block.chainid == 421614 || block.chainid == 167008) {
            _setOracleFee(sepoliaChainId, gas * gasPrice);
        }
        // pangolin
        if (block.chainid == 43) {
            _setOracleFee(sepoliaChainId, usd / ringPrice);
        }
    }

    function setArbitrumSepoliaOracleFee() internal {
        uint256 arbitrumSepoliaChainId = 421614;
        uint256 gas = 110000 / 100;
        uint256 usd = gas * gasPrice * ethPrice / 1e18;
        if (block.chainid == arbitrumSepoliaChainId) {
            return;
        }
        // sepolia, taiko-katla, arbitrum-sepolia
        if (block.chainid == 11155111 || block.chainid == 167008) {
            _setOracleFee(arbitrumSepoliaChainId, gas * gasPrice);
        }
        // pangolin
        if (block.chainid == 43) {
            _setOracleFee(arbitrumSepoliaChainId, usd / ringPrice);
        }
    }

    function setPangolinOracleFee() internal {
        uint256 pangolinChainId = 43;
        uint256 gas = 110000;
        uint256 usd = gas * gasPrice * ringPrice / 1e18;
        if (block.chainid == pangolinChainId) {
            return;
        }
        // sepolia, arbitrum-sepolia, taiko-katla
        if (block.chainid == 11155111 || block.chainid == 421614 || block.chainid == 167008) {
            _setOracleFee(pangolinChainId, usd / ethPrice);
        }
    }

    function setTaikoKatlaOracleFee() internal {
        uint256 taikoKatlaChainId = 167008;
        uint256 gas = 110000 / 100;
        uint256 usd = gas * gasPrice * ethPrice / 1e18;
        if (block.chainid == taikoKatlaChainId) {
            return;
        }
        // sepolia, arbitrum-sepolia
        if (block.chainid == 11155111 || block.chainid == 421614) {
            _setOracleFee(taikoKatlaChainId, gas * gasPrice);
        }
        // pangolin
        if (block.chainid == 43) {
            _setOracleFee(taikoKatlaChainId, usd / ringPrice);
        }
    }

    function _setOracleFee(uint256 chainId, uint256 fee) internal {
        if (fee != oracle.feeOf(chainId)) {
            oracle.setFee(chainId, fee);
        }
    }
}
