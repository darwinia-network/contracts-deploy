// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Connect.s.sol";
import "../self/SwapOwner.s.sol";

contract OneClickScript is ConnectScript {
    SwapOwnerScript swap = new SwapOwnerScript();

    function run() public override sphinx {
        deploy.run();
        super.run();
        swap.run();
    }
}
