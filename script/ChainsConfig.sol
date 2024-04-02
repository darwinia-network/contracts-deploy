// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Constants.sol";

/// @notice Chain IDs for the various networks.
contract ChainsConfig is Constants {
    mapping(uint256 => string) public chainNameOf;
    mapping(string => uint256) public chainIdOf;

    error NotFoundChainId(uint256 chainId);
    error NotFoundChainName(string chainName);
    error AlreadAddedChainId(uint256 chainId);
    error AlreadAddedChainName(string chainName);

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

    function addChain(string memory chainName, uint256 chainId) public {
        string memory n = chainNameOf[chainId];
        if (bytes(n).length != 0) {
            revert AlreadAddedChainId(chainId);
        }
        uint256 id = chainIdOf[chainName];
        if (id != 0) {
            revert AlreadAddedChainName(chainName);
        }

        chainIdOf[chainName] = chainId;
        chainNameOf[chainId] = chainName;
    }

    function toChainName(uint256 chainId)
        public
        view
        returns (string memory name)
    {
        name = chainNameOf[chainId];
        if (bytes(name).length == 0) {
            revert NotFoundChainId(chainId);
        }
    }

    function toChainId(string memory chainName)
        public
        view
        returns (uint256 chainId)
    {
        chainId = chainIdOf[chainName];
        if (chainId == 0) {
            revert NotFoundChainName(chainName);
        }
    }

    function isL2(uint256 chainId) internal pure returns (bool) {
        if (chainId == Ethereum) return false;
        else return true;
    }
}
