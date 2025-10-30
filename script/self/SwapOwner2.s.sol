// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";

interface ISafe {
    function swapOwner(address prevOwner, address oldOwner, address newOwner) external;
}

interface IRelayer {
    function isApproved(address) external view returns (bool);
    function setApproved(address, bool) external;
}

contract SwapOwner2Script is Base {
    address guantong = 0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85;
    address xiaoch = 0x88a39B052d477CfdE47600a7C9950a441Ce61cb4;

	address alex = 0x00E3993566b34e5367d1C602439997BD08c11FF7;
	address yalin = 0x9a3b34f81F8005709409eAf65AEcA4530011f88d;

    address relayer = 0x114890eB7386F94eae410186F20968bFAf66142a;

    function run() public sphinx {
        _run();
    }

    function _run() internal virtual {
        address self = safeAddress();

        ISafe(self).swapOwner(address(0x1), alex, yalin);
        ISafe(self).swapOwner(0x5b7544b3f6aBd9E03Fba494796B1eE6F9543E2e4, guantong, xiaoch);

        if (IRelayer(relayer).isApproved(guantong)) {
            IRelayer(relayer).setApproved(guantong, false);
        }
    }
}
