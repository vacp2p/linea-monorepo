# Status Network

## Devnet

### 📬 Devnet Deployed Contracts

These are the official contract deployments on the **Holesky** for L1 and Status Devnet for L2.

| Chain   | Contract                         | Address                                                                                             |
|---------|----------------------------------|-----------------------------------------------------------------------------------------------------|
| Hoodi       | **Yield Manager**                | [0xF62923E542BdEA2DeC8Da020480197A54c4CE53A](https://hoodi.etherscan.io/address/0xF62923E542BdEA2DeC8Da020480197A54c4CE53A#code)|
| Hoodi       | **L1ETHBridge (Proxy)** | [0x0958faaa350be3d11c9f9a2ba366af3dab16c792](https://hoodi.etherscan.io/address/0x0958faaa350be3d11c9f9a2ba366af3dab16c792#code)|
| Hoodi       | **L1ETHBridge (Implementation)** | [0x968b487d38d93fd5a36aed69da52febcc043c3e7](https://hoodi.etherscan.io/address/0x968b487d38d93fd5a36aed69da52febcc043c3e7#code)|
| Status Devnet | **L2ETHBridge (Proxy)** | [0x99751AD60328ABf73e8c938c0B7A9F9FD370f453](https://sunti-blockscout.eu-north-2.gateway.fm/address/0x99751AD60328ABf73e8c938c0B7A9F9FD370f453?tab=contract)|
| Status Devnet | **L2ETHBridge (Implementation)** | [0xCaF71dEe9d59d0095eC37c1FFa7E4b8fD3114Bc2](https://sunti-blockscout.eu-north-2.gateway.fm/address/0xCaF71dEe9d59d0095eC37c1FFa7E4b8fD3114Bc2?tab=contract)|



The devnet test deployer is `0xD631542acd56eeBe466F16CBfEb937637b8b43c1`.

### YieldManager

Deploy a Dummy YieldManager contract on the Status Devnet.

```bash
export ETH_FROM=0xD631542acd56eeBe466F16CBfEb937637b8b43c1

forge script \
  script/yield/bridge/l1/DeployDummyYieldManager.s.sol \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $STATUS_DEVNET_DEPLOYER_KEY \
  --broadcast
```

Verify the contract on Etherscan:

```bash
forge verify-contract --chain hoodi CONTRACT_ADDRESS ETHYieldManagerMock
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
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $STATUS_DEVNET_DEPLOYER_KEY \
  --broadcast
```

Verify the implementation contract on Blockscout:

```bash
forge verify-contract --chain hoodi CONTRACT_ADDRESS L1ETHBridge
```


### L2ETHBridge


Update the deployment config (`script/yield/bridge/l2/DeploymentConfig.s.sol`) to include the address of the `L1ETHBridge` contract deployed above.

```bash
export ETH_FROM=0xD631542acd56eeBe466F16CBfEb937637b8b43c1

forge script \
  script/yield/bridge/l2/DeployL2ETHBridge.s.sol \
  --rpc-url https://sunti-rpc.eu-north-2.gateway.fm/ \
  --private-key $STATUS_DEVNET_DEPLOYER_KEY \
  --broadcast
```

Verify the implementation contract on Blockscout:

```bash
forge verify-contract \
  --verifier blockscout \
  --compilation-profile london \
  --verifier-url https://sunti-blockscout.eu-north-2.gateway.fm/api \
  --chain 1706707152 \
  IMPLEMENTATION_ADDRESS \
  L2ETHBridge
```

Verify the proxy contract in case it hasn't been verified yet automatically by Blockscout:

```bash
forge verify-contract \
  --verifier blockscout \
  --compilation-profile london \
  --verifier-url https://sunti-blockscout.eu-north-2.gateway.fm/api \
  --chain 1706707152 \
  PROXY_ADDRESS \
  node_modules/@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy
```

Remember to set the `L2ETHBridge` address in the `L1ETHBridge` contract calling the `setRemoteSender` function.
