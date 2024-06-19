// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base} from "../common/Base.sol";

interface XTokenBase {
    struct MessagerService {
        address sendService;
        address receiveService;
    }

    function setSendService(uint256 remoteChainId, address remoteBridge, address service) external;
    function setReceiveService(uint256 remoteChainId, address remoteBridge, address service) external;
    function messagers(uint256) external view returns (MessagerService memory);
}

interface IOwnership {
    function dao() external view returns (address);
    function pendingDao() external view returns (address);
    function acceptOwnership() external;
}

contract ConfigScript is Base {
    address backingAddress = 0x2B496f19A420C02490dB859fefeCCD71eDc2c046;
    address issuingAddress = 0xDc0C760c0fB4672D06088515F6446a71Df0c64C1;
    address oldMessagerOnDarwinia = 0x65Be094765731F394bc6d9DF53bDF3376F1Fc8B0;
    address oldMessagerOnEthereum = 0x65Be094765731F394bc6d9DF53bDF3376F1Fc8B0;
    address newMessagerOnDarwinia = 0x682294D1c00A9CA13290b53B7544b8F734D6501f;
    address newMessagerOnEthereum = 0x02e5C0a36Fb0C83CCEBCD4D6177A7E223D6f0b7c;

    uint256 ETHEREUM_CHAINID = 1;
    uint256 DARWINIA_CHAINID = 46;

    function run() public sphinx {
        address dao = safeAddress();
        if (block.chainid == DARWINIA_CHAINID) {
            if (IOwnership(backingAddress).pendingDao() == dao) {
                IOwnership(backingAddress).acceptOwnership();
            }

            if (IOwnership(newMessagerOnDarwinia).pendingDao() == dao) {
                IOwnership(newMessagerOnDarwinia).acceptOwnership();
            }

            XTokenBase backing = XTokenBase(backingAddress);
            require(backing.messagers(ETHEREUM_CHAINID).sendService == oldMessagerOnDarwinia, "!oldMessager");
            require(backing.messagers(ETHEREUM_CHAINID).receiveService == oldMessagerOnDarwinia, "!oldMessager");
            backing.setSendService(ETHEREUM_CHAINID, issuingAddress, newMessagerOnDarwinia);
            backing.setReceiveService(ETHEREUM_CHAINID, issuingAddress, newMessagerOnDarwinia);
            require(backing.messagers(ETHEREUM_CHAINID).sendService == newMessagerOnDarwinia, "!newMessager");
            require(backing.messagers(ETHEREUM_CHAINID).receiveService == newMessagerOnDarwinia, "!newMessager");
        } else if (block.chainid == ETHEREUM_CHAINID) {
            if (IOwnership(issuingAddress).pendingDao() == dao) {
                IOwnership(issuingAddress).acceptOwnership();
            }

            if (IOwnership(newMessagerOnEthereum).pendingDao() == dao) {
                IOwnership(newMessagerOnEthereum).acceptOwnership();
            }

            XTokenBase issuing = XTokenBase(issuingAddress);
            require(issuing.messagers(DARWINIA_CHAINID).sendService == oldMessagerOnEthereum, "!oldMessager");
            require(issuing.messagers(DARWINIA_CHAINID).receiveService == oldMessagerOnEthereum, "!oldMessager");
            issuing.setSendService(DARWINIA_CHAINID, backingAddress, newMessagerOnEthereum);
            issuing.setReceiveService(DARWINIA_CHAINID, backingAddress, newMessagerOnEthereum);
            require(issuing.messagers(DARWINIA_CHAINID).sendService == newMessagerOnEthereum, "!newMessager");
            require(issuing.messagers(DARWINIA_CHAINID).receiveService == newMessagerOnEthereum, "!newMessager");
        }
    }
}
