// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VmSafe} from "forge-std/Vm.sol";
import {stdToml} from "forge-std/StdToml.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract RelayerConfig {
    using stdToml for string;
    using SafeCast for uint256;

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct Config {
        uint128 dstPriceRatio; // dstPrice / localPrice * 10^10
        uint128 dstGasPriceInWei;
        uint64 baseGas;
        uint64 gasPerByte;
    }

    // local => remote => ...
    mapping(uint256 => mapping(uint256 => Config)) public configOf;

    error NotFoundRelayerConfig(uint256 local, uint256 remote);

    function init(uint256 local, string memory config) public virtual {
        uint256[] memory remotes = config.readUintArray(".remote.chains");
        uint256 len = remotes.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 remote = remotes[i];
            string memory key = string.concat(".ormp.relayer.", vm.toString(remote));
            string memory key1 = string.concat(key, ".dstPriceRatio");
            string memory key2 = string.concat(key, ".dstGasPriceInWei");
            string memory key3 = string.concat(key, ".baseGas");
            string memory key4 = string.concat(key, ".gasPerByte");
            uint256 dstPriceRatio = config.readUint(key1);
            uint256 dstGasPriceInWei = config.readUint(key2);
            uint256 baseGas = config.readUint(key3);
            uint256 gasPerByte = config.readUint(key4);
            setRelayerConfig(
                local,
                remote,
                dstPriceRatio.toUint128(),
                dstGasPriceInWei.toUint128(),
                baseGas.toUint64(),
                gasPerByte.toUint64()
            );
        }
    }

    function setRelayerConfig(
        uint256 local,
        uint256 remote,
        uint128 dstPriceRatio,
        uint128 dstGasPriceInWei,
        uint64 baseGas,
        uint64 gasPerByte
    ) public {
        configOf[local][remote] = Config(dstPriceRatio, dstGasPriceInWei, baseGas, gasPerByte);
    }

    function getRelayerConfig(uint256 local, uint256 remote) public view returns (Config memory c) {
        c = configOf[local][remote];
        // if (c.baseGas == 0) revert NotFoundRelayerConfig(local, remote);
    }
}
