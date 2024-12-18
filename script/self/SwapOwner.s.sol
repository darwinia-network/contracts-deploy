// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";

interface ISafe {
    function swapOwner(address prevOwner, address oldOwner, address newOwner) external;
}

contract SwapOwnerScript is Base {
    address aki = 0x53405FB4d71591E33fe07bFbC90bD82E65720ad0;
    address bear = 0x5b7544b3f6aBd9E03Fba494796B1eE6F9543E2e4;

    function _run() internal virtual {
        address self = safeAddress();
        ISafe(self).swapOwner(0x52386BE2397e8EAc26298F733b390684203fB580, aki, bear);
    }
}
