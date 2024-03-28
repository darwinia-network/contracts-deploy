.PHONY: all fmt clean test
.PHONY: tools foundry sync

-include .env



all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
deploy :; @npx sphinx deploy  ./script/Deploy.s.sol --network  $(chain) --verify --confirm

propose-test:; @SPHINX_API_KEY=$(SPHINX_API_KEY) npx sphinx propose ./script/Deploy.s.sol --networks testnets 
propose-prod:; @SPHINX_API_KEY=$(SPHINX_API_KEY) npx sphinx propose ./script/Deploy.s.sol --networks mainnets 

sync   :; @git submodule update --recursive
tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash
