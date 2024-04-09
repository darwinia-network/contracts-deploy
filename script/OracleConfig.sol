// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VmSafe} from "forge-std/Vm.sol";
import {stdToml} from "forge-std/StdToml.sol";

contract OracleConfig {
    using stdToml for string;

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    // local => remote
    mapping(uint256 => mapping(uint256 => uint256)) public oracleFeeOf;

    error NotFoundOracleConfig(uint256 local, uint256 remote);

    function init(uint256 local, string memory config) public virtual {
        uint256[] memory remotes = config.readUintArray(".remote.chains");
        uint256 len = remotes.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 remote = remotes[i];
            string memory key = string.concat(".oracle.", vm.toString(remote), ".fee");
            uint256 fee = config.readUint(key);
            setOracleConfig(local, remote, fee);
        }
    }

    function setOracleConfig(uint256 local, uint256 remote, uint256 fee) public {
        oracleFeeOf[local][remote] = fee;
    }

    function getOracleConfig(uint256 local, uint256 remote) public view returns (uint256 fee) {
        fee = oracleFeeOf[local][remote];
        if (fee == 0) revert NotFoundOracleConfig(local, remote);
    }
}
