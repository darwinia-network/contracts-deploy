// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";

import "@openzeppelin/contracts/access/IAccessControl.sol";

contract ConfigScript is Base {
    address depoist = 0x53E294d1B6ec28B251A81aa337212D7a48E6B642;
    address timelock = 0x849eC3ba6AD79934666Bb98eCd74cF94F5dA3835;
    address gRING = 0xD358c5c694A12857C3A44b53943fB5ca6b042764;
    address ringDAO = 0x2E05EE9032a28d894545708C56BE7bccd2e47826;
    address hub = 0xC5d919D01DB0f225AAf2Bb45Fd4f65dC0d173D75;

    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    function run() public sphinx {
        if (!IAccessControl(timelock).hasRole(PROPOSER_ROLE, ringDAO)) {
            IAccessControl(timelock).grantRole(PROPOSER_ROLE, ringDAO);
        }
        if (!IAccessControl(gRING).hasRole(MINTER_ROLE, hub)) IAccessControl(gRING).grantRole(MINTER_ROLE, hub);
        if (!IAccessControl(gRING).hasRole(BURNER_ROLE, hub)) IAccessControl(gRING).grantRole(BURNER_ROLE, hub);
    }
}
