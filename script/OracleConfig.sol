// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Constants.sol";

contract OracleConfig is Constants {
    // local => remote
    mapping(uint256 => uint256) oracleFeeOf;

    error NotFoundOracleConfig(uint256 local, uint256 remote);

    constructor() {
        oracleFeeOf[ArbitrumSepolia][Sepolia] = 2750000000000000;
        oracleFeeOf[Pangolin][Sepolia] = 1980000000000000000000;

        oracleFeeOf[Sepolia][ArbitrumSepolia] = 27500000000000;
        oracleFeeOf[Pangolin][ArbitrumSepolia] = 19800000000000000000;

        oracleFeeOf[Sepolia][Pangolin] = 50000000000;
        oracleFeeOf[ArbitrumSepolia][Pangolin] = 50000000000;
    }

    function setOracleConfig(uint256 local, uint256 remote, uint256 fee)
        public
    {
        oracleFeeOf[local][remote] = fee;
    }

    function getOracleConfig(uint256 local, uint256 remote)
        public
        view
        returns (uint256 fee)
    {
        fee = oracleFeeOf[local][remote];
        if (fee == 0) revert NotFoundOracleConfig(local, remote);
    }
}
