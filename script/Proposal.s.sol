// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// import "./x-account/Deploy.s.sol";
import "./self/SwapOwner.s.sol";

contract Proposal is SwapOwnerScript {
    function run() public sphinx {
        _run();
    }
}
