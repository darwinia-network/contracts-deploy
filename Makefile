.PHONY: all fmt clean test
.PHONY: tools foundry sync

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
deploy :; npx sphinx deploy  ./script/Deploy.s.sol  --network $(chain) --confirm --verify
connect:; npx sphinx deploy  ./script/Connect.s.sol --network $(chain) --confirm

propose-deploy-test  :; npx sphinx propose ./script/Deploy.s.sol  --networks testnets
propose-deploy-prod  :; npx sphinx propose ./script/Deploy.s.sol  --networks mainnets
propose-connect-test :;	npx sphinx propose ./script/Connect.s.sol --networks testnets

sphinx :; @npx sphinx install
sync   :; @git submodule update --recursive
tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash
