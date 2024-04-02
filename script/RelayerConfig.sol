// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Constants.sol";

contract RelayerConfig is Constants {
    struct Config {
        uint128 dstPriceRatio; // dstPrice / localPrice * 10^10
        uint128 dstGasPriceInWei;
        uint64 baseGas;
        uint64 gasPerByte;
    }

    // local => remote => ...
    mapping(uint256 => mapping(uint256 => Config)) public configOf;

    error NotFoundRelayerConfig(uint256 local, uint256 remote);

    constructor() {
        configOf[ArbitrumSepolia][Sepolia] = Config({
            dstPriceRatio: 10000000000,
            dstGasPriceInWei: 25000000000,
            baseGas: 120000,
            gasPerByte: 16
        });
        configOf[Pangolin][Sepolia] = Config({
            dstPriceRatio: 7200000000000000,
            dstGasPriceInWei: 25000000000,
            baseGas: 120000,
            gasPerByte: 16
        });

        configOf[Sepolia][ArbitrumSepolia] = Config({
            dstPriceRatio: 10000000000,
            dstGasPriceInWei: 110000000,
            baseGas: 1,
            gasPerByte: 16
        });
        configOf[Pangolin][ArbitrumSepolia] = Config({
            dstPriceRatio: 7200000000000000,
            dstGasPriceInWei: 110000000,
            baseGas: 1,
            gasPerByte: 16
        });

        configOf[Sepolia][Pangolin] = Config({
            dstPriceRatio: 13888,
            dstGasPriceInWei: 160000000000,
            baseGas: 200000,
            gasPerByte: 16
        });
        configOf[ArbitrumSepolia][Pangolin] = Config({
            dstPriceRatio: 13888,
            dstGasPriceInWei: 160000000000,
            baseGas: 200000,
            gasPerByte: 16
        });
    }

    function setRelayerConfig(
        uint256 local,
        uint256 remote,
        uint128 dstPriceRatio,
        uint128 dstGasPriceInWei,
        uint64 baseGas,
        uint64 gasPerByte
    ) public {
        configOf[local][remote] =
            Config(dstPriceRatio, dstGasPriceInWei, baseGas, gasPerByte);
    }

    function getRelayerConfig(uint256 local, uint256 remote)
        public
        view
        returns (Config memory c)
    {
        c = configOf[local][remote];
        if (c.baseGas == 0) revert NotFoundRelayerConfig(local, remote);
    }
}
