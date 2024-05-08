// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@sphinx-labs/contracts/SphinxPlugin.sol";
import {SphinxConstants, NetworkInfo} from "@sphinx-labs/contracts/SphinxConstants.sol";
import {Script} from "forge-std/Script.sol";
import {stdToml} from "forge-std/StdToml.sol";

import {CREATE3Factory, ICREATE3Factory} from "create3-deploy/src/CREATE3Factory.sol";

abstract contract Base is Script, Sphinx, SphinxConstants {
    using stdToml for string;

    address immutable CREATE2_ADDR = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    error CREATE2FactoryNotDeployed();

    function configureSphinx() public override {
        sphinxConfig.owners = [
            0x0f14341A7f464320319025540E8Fe48Ad0fe5aec,
            0x53405FB4d71591E33fe07bFbC90bD82E65720ad0,
            0x00E3993566b34e5367d1C602439997BD08c11FF7,
            0x52386BE2397e8EAc26298F733b390684203fB580,
            0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85
        ];
        sphinxConfig.orgId = "cluanacaw000111jik4xs4wkl";
        sphinxConfig.projectName = "RING-DAO";
        sphinxConfig.threshold = 3;
        sphinxConfig.testnets = ["sepolia", "darwinia_pangolin", "arbitrum_sepolia"];
        // sphinxConfig.mainnets = [];
        // sphinxConfig.saltNonce = 0;
    }

    function CREATE3() public returns (address create3) {
        bytes memory byteCode = type(CREATE3Factory).creationCode;
        bytes32 salt = bytes32(0);
        create3 = computeAddress(salt, hash(byteCode));
        if (create3.code.length == 0) _deploy2(salt, byteCode);
    }

    function _deploy3(bytes32 salt, bytes memory initCode) internal returns (address) {
        return ICREATE3Factory(CREATE3()).deploy(salt, initCode);
    }

    function _deploy2(bytes32 salt, bytes memory initCode) internal returns (address) {
        if (CREATE2_ADDR.code.length == 0) revert CREATE2FactoryNotDeployed();
        bytes memory data = bytes.concat(salt, initCode);
        (, bytes memory addr) = CREATE2_ADDR.call(data);
        return address(uint160(bytes20(addr)));
    }

    function computeCreate3Address(bytes32 salt) internal returns (address) {
        return ICREATE3Factory(CREATE3()).getDeployed(safeAddress(), salt);
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address addr) {
        address deployer = CREATE2_ADDR;
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer)
            let start := add(ptr, 0x0b)
            mstore8(start, 0xff)
            addr := and(keccak256(start, 85), 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }

    function hash(bytes memory data) internal pure returns (bytes32) {
        return keccak256(data);
    }

    function hash(string memory data) internal pure returns (bytes32) {
        return hash(bytes(data));
    }

    function isL2(uint256 chainId) internal pure returns (bool) {
        if (chainId == 1) return false;
        else return true;
    }

    function getChainId(string memory name) public pure returns (uint256 chaindId) {
        return findNetworkInfoByName(name).chainId;
    }

    function findNetworkInfoByName(string memory _networkName) public pure returns (NetworkInfo memory) {
        NetworkInfo[] memory all = getNetworkInfoArray();
        for (uint256 i = 0; i < all.length; i++) {
            if (keccak256(abi.encode(all[i].name)) == keccak256(abi.encode(_networkName))) {
                return all[i];
            }
        }
        revert(string(abi.encodePacked("Sphinx: No network found with the given name: ", _networkName)));
    }
}
