.PHONY: all fmt clean test
.PHONY: tools foundry sync

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean

dry-run       :; npx sphinx propose ./script/Proposal.s.sol --networks mainnets
propose-test  :; npx sphinx propose ./script/Proposal.s.sol --networks testnets
propose-prod  :; npx sphinx propose ./script/Proposal.s.sol --networks mainnets

execute :; npx sphinx execute $(path)

sphinx :; @npx sphinx install
sync   :; @git submodule update --recursive
tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash
