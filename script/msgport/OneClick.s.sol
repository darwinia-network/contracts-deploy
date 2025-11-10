// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Connect.s.sol";
import "./Deploy.s.sol";
import "../self/SwapOwner.s.sol";

contract OneClickScript is DeployScript, ConnectScript, SwapOwnerScript {
    SwapOwnerScript swap = new SwapOwnerScript();

    function run() public sphinx {
        _run();
    }

    function _run() internal override(DeployScript, ConnectScript, SwapOwnerScript) {
        DeployScript._run();
        ConnectScript._run();
        // SwapOwnerScript._run();
    }
}
