// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";

interface XTokenBase {
    function originalTokens(address) external view returns (uint256, address);
    function updateXToken(uint256, address, address) external;
    function setDailyLimit(address, uint256) external;
}

interface IOwnership {
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function acceptOwnership() external;
    function acceptXTokenOwnership(address) external;
}

contract UpdateXTokenXKTONScript is Base {
    address issuing = 0xDc0C760c0fB4672D06088515F6446a71Df0c64C1;
    address KTON = 0x9F284E1337A815fe77D2Ff4aE46544645B20c5ff;
    address xKTON = 0x35f15275041B53324dF461d5ccC952EE19D4a982;

    uint256 ETHEREUM_CHAINID = 1;

    function run() public sphinx {
        if (block.chainid == ETHEREUM_CHAINID) {
            if (IOwnership(xKTON).pendingOwner() == issuing) {
                IOwnership(issuing).acceptXTokenOwnership(xKTON);
            }
        }
        (, address oKTON) = XTokenBase(issuing).originalTokens(xKTON);
        if (oKTON != address(0)) {
            XTokenBase(issuing).updateXToken(46, 0x0000000000000000000000000000000000000402, xKTON);
            XTokenBase(issuing).setDailyLimit(xKTON, 50_000 ether);
        }
    }
}
