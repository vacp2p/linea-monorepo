# Status Network

## Devnet

### 📬 Devnet Deployed Contracts

These are the official contract deployments on the **Holesky** for L1 and Status Devnet for L2.

| Chain   | Contract                         | Address                                                                                             |
|---------|----------------------------------|-----------------------------------------------------------------------------------------------------|
| Holesky       | **Yield Manager**                | [0xcaf71dee9d59d0095ec37c1ffa7e4b8fd3114bc2](https://holesky.etherscan.io/address/0xcaf71dee9d59d0095ec37c1ffa7e4b8fd3114bc2#code)|
| Holesky       | **L1ETHBridge (Proxy)** | [0xF62923E542BdEA2DeC8Da020480197A54c4CE53A](https://holesky.etherscan.io/address/0xF62923E542BdEA2DeC8Da020480197A54c4CE53A#code)|
| Holesky       | **L1ETHBridge (Implementation)** | [0x99751ad60328abf73e8c938c0b7a9f9fd370f453](https://holesky.etherscan.io/address/0x99751ad60328abf73e8c938c0b7a9f9fd370f453#code)|
| Status Devnet | **L2ETHBridge (Proxy)** | [0x99751AD60328ABf73e8c938c0B7A9F9FD370f453](https://pumpi-blockscout.eu-north-2.gateway.fm/address/0x99751AD60328ABf73e8c938c0B7A9F9FD370f453)|
| Status Devnet | **L2ETHBridge (Implementation)** | [0xCaF71dEe9d59d0095eC37c1FFa7E4b8fD3114Bc2](https://pumpi-blockscout.eu-north-2.gateway.fm/address/0xCaF71dEe9d59d0095eC37c1FFa7E4b8fD3114Bc2)|



The devnet test deployer is `0xD631542acd56eeBe466F16CBfEb937637b8b43c1`.

### YieldManager

Deploy a Dummy YieldManager contract on the Status Devnet.

```bash
export ETH_FROM=0xD631542acd56eeBe466F16CBfEb937637b8b43c1

forge script \
  script/yield/bridge/l1/DeployDummyYieldManager.s.sol \
  --rpc-url https://ethereum-holesky-rpc.publicnode.com \
  --private-key $STATUS_DEVNET_DEPLOYER_KEY \
  --broadcast
```

Verify the contract on Etherscan:

```bash
forge verify-contract --chain holesky CONTRACT_ADDRESS ETHYieldManagerMock
```

### L1ETHBridge

Update the deployment config (`script/yield/bridge/l1/DeploymentConfig.s.sol`) to include the address of the `YieldManager` contract deployed above.

The deployment config requires the address of the `L2ETHBridge` contract, which is the bridge on the L2 chain (Status Devnet).
If it's the first deployment, you won't have the `L2ETHBridge` deployed yet, so you need to set a temporary one like 0x1
in the config script that must different from the zero address otherwise the deployment will fail.

```bash
export ETH_FROM=0xD631542acd56eeBe466F16CBfEb937637b8b43c1

forge script \
  script/yield/bridge/l1/DeployL1ETHBridge.s.sol \
  --rpc-url https://ethereum-holesky-rpc.publicnode.com \
  --private-key $STATUS_DEVNET_DEPLOYER_KEY \
  --broadcast
```


### L2ETHBridge


Update the deployment config (`script/yield/bridge/l2/DeploymentConfig.s.sol`) to include the address of the `L1ETHBridge` contract deployed above.

```bash
export ETH_FROM=0xD631542acd56eeBe466F16CBfEb937637b8b43c1

forge script \
  script/yield/bridge/l2/DeployL2ETHBridge.s.sol \
  --rpc-url https://pumpi-rpc.eu-north-2.gateway.fm/ \
  --private-key $STATUS_DEVNET_DEPLOYER_KEY \
  --broadcast
```

Verify the implementation contract on Blockscout:

```bash
forge verify-contract \
  --verifier blockscout \
  --compilation-profile london \
  --verifier-url https://pumpi-blockscout.eu-north-2.gateway.fm/api \
  --chain 762355666 \
  IMPLEMENTATION_ADDRESS \
  L2ETHBridge
```

Verify the proxy contract in case it hasn't been verified yet automatically by Blockscout:

```bash
forge verify-contract \
  --verifier blockscout \
  --compilation-profile london \
  --verifier-url https://pumpi-blockscout.eu-north-2.gateway.fm/api \
  --chain 762355666 \
  PROXY_ADDRESS \
  node_modules/@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy
```

Remember to set the `L2ETHBridge` address in the `L1ETHBridge` contract calling the `setRemoteSender` function.
