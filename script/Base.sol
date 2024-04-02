// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@sphinx-labs/contracts/SphinxPlugin.sol";

abstract contract Base is Sphinx {
    address immutable SAFE_CREATE2_ADDR =
        0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;

    function configureSphinx() public override {
        sphinxConfig.owners = [0xD70A2e6eACbdeDA77a5d4bBAE3bC70239A0e088f];
        sphinxConfig.orgId = "cluanacaw000111jik4xs4wkl";
        sphinxConfig.projectName = "Msgport";
        sphinxConfig.threshold = 1;
        // sphinxConfig.testnets = ["sepolia", "pangolin", "arbitrum_sepolia", "taiko_katla"];
        sphinxConfig.testnets = ["sepolia", "arbitrum_sepolia", "taiko_katla"];
    }

    function _deploy2(bytes32 salt, bytes memory initCode)
        internal
        returns (address)
    {
        bytes memory data = bytes.concat(salt, initCode);
        (, bytes memory addr) = SAFE_CREATE2_ADDR.call(data);
        return address(uint160(bytes20(addr)));
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash)
        internal
        view
        returns (address addr)
    {
        address deployer = SAFE_CREATE2_ADDR;
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer)
            let start := add(ptr, 0x0b)
            mstore8(start, 0xff)
            addr :=
                and(
                    keccak256(start, 85), 0xffffffffffffffffffffffffffffffffffffffff
                )
        }
    }

    function hash(bytes memory data) internal pure returns (bytes32) {
        return keccak256(data);
    }

    function hash(string memory data) internal pure returns (bytes32) {
        return hash(bytes(data));
    }
}
