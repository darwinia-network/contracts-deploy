// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from "forge-std/Vm.sol";

/// @notice Chain IDs for the various networks.
contract Chains {
    uint256 internal constant Ethereum = 1;
    uint256 internal constant Goerli = 5;
    uint256 internal constant Optimism = 10;
    uint256 internal constant Pangolin = 43;
    uint256 internal constant Crab = 44;
    uint256 internal constant Darwinia = 46;
    uint256 internal constant Polygon = 137;
    uint256 internal constant Zksync = 324;
    uint256 internal constant Mantle = 5000;
    uint256 internal constant Anvil = 31337;
    uint256 internal constant Arbitrum = 42161;
    uint256 internal constant Mumbai = 80001;
    uint256 internal constant Blast = 81457;
    uint256 internal constant TaikoKatla = 167008;
    uint256 internal constant ArbitrumSepolia = 421614;
    uint256 internal constant Sepolia = 11155111;
    uint256 internal constant OptimismSepolia = 11155420;
    Vm constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    mapping(uint256 => string) public chainNameOf;
    mapping(string => uint256) public chainIdOf;

    constructor() {
        chainIdOf["ethereum"] = Ethereum;
        chainNameOf[Ethereum] = "ethereum";

        chainIdOf["goerli"] = Goerli;
        chainNameOf[Goerli] = "goerli";

        chainIdOf["optimism"] = Optimism;
        chainNameOf[Optimism] = "optimism";

        chainIdOf["pangolin"] = Pangolin;
        chainNameOf[Pangolin] = "pangolin";

        chainIdOf["crab"] = Crab;
        chainNameOf[Crab] = "Crab";

        chainIdOf["darwinia"] = Darwinia;
        chainNameOf[Darwinia] = "darwinia";

        chainIdOf["polygon"] = Polygon;
        chainNameOf[Polygon] = "polygon";

        chainIdOf["zksync"] = Zksync;
        chainNameOf[Zksync] = "zksync";

        chainIdOf["mantle"] = Mantle;
        chainNameOf[Mantle] = "mantle";

        chainIdOf["anvil"] = Anvil;
        chainNameOf[Anvil] = "anvil";

        chainIdOf["arbitrum"] = Arbitrum;
        chainNameOf[Arbitrum] = "arbitrum";

        chainIdOf["mumbai"] = Mumbai;
        chainNameOf[Mumbai] = "mumbai";

        chainIdOf["blast"] = Blast;
        chainNameOf[Blast] = "blast";

        chainIdOf["taiko_katla"] = TaikoKatla;
        chainNameOf[TaikoKatla] = "taiko_katla";

        chainIdOf["arbitrum_sepolia"] = ArbitrumSepolia;
        chainNameOf[ArbitrumSepolia] = "arbitrum_sepolia";

        chainIdOf["sepolia"] = Sepolia;
        chainNameOf[Sepolia] = "sepolia";

        chainIdOf["optimism_sepolia"] = OptimismSepolia;
        chainNameOf[OptimismSepolia] = "optimism_sepolia";
    }

    function addChain(string memory chainName, uint256 chainid) public {
        string memory n = chainNameOf[chainid];
        if (bytes(n).length != 0) {
            revert(string(abi.encodePacked("Already add: ", vm.toString(chainid))));
        }
        uint256 id = chainIdOf[chainName];
        if (id != 0) {
            revert(string(abi.encodePacked("Already add: ", chainName)));
        }

        chainIdOf[chainName] = chainid;
        chainNameOf[chainid] = chainName;
    }

    function toChainName(uint256 chainid) public view returns (string memory name) {
        name = chainNameOf[chainid];
        if (bytes(name).length == 0) {
            revert(string(abi.encodePacked("No network found with the chain ID: ", vm.toString(chainid))));
        }
    }

    function toChainId(string memory chainName) public view returns (uint256 chainid) {
        chainid = chainIdOf[chainName];
        if (chainid == 0) {
            revert(string(abi.encodePacked("No network found with the chain name: ", chainName)));
        }
    }

    function isL2(uint256 chainid) internal pure returns (bool) {
        if (chainid == Ethereum) return false;
        else return true;
    }
}
