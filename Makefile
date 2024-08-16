-include .env

build:;forge build

deploy:
	forge test --fork-url $(SEPOLIA_RPC_URL)