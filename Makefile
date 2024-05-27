.PHONY: all fmt clean test
.PHONY: tools foundry sync

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
deploy :; npx sphinx deploy  ./script/Deploy.s.sol  --network $(chain) --confirm --verify
connect:; npx sphinx deploy  ./script/Connect.s.sol --network $(chain) --confirm

dry-run       :; npx sphinx propose ./script/common/Proposal.s.sol  --networks mainnets
propose-test  :; npx sphinx propose ./script/common/Proposal.s.sol  --networks testnets
propose-prod  :; npx sphinx propose ./script/common/Proposal.s.sol  --networks mainnets

execute :; npx sphinx execute $(path)

sphinx :; @npx sphinx install
sync   :; @git submodule update --recursive
tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash
