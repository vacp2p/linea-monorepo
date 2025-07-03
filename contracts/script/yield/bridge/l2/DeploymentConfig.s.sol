// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { L2MessageServiceMock } from "../../../../test/foundry/bridging/eth/mocks/L2MessageServiceMock.sol";

contract DeploymentConfig is Script {
  error DeploymentConfig_InvalidDeployerAddress();
  error DeploymentConfig_NoConfigForChain(uint256);

  struct NetworkConfig {
    address deployer;
    address l2MessageService;
    address l1ETHBridge;
  }

  NetworkConfig public activeNetworkConfig;

  address private deployer;

  // solhint-disable-next-line var-name-mixedcase
  address internal L2_MESSAGE_SERVICE_ADDRESS_DEVNET = 0x1722E194Fc02858243b9b1f59ed2b41202cb4351;

  // solhint-disable-next-line var-name-mixedcase
  address internal L1_ETH_BRIDGE_ADDRESS_HOODI = 0x0958FAAA350bE3d11C9f9A2BA366af3DAb16C792;

  constructor(address _broadcaster) {
    if (_broadcaster == address(0)) revert DeploymentConfig_InvalidDeployerAddress();
    deployer = _broadcaster;
    if (block.chainid == 31_337) {
      activeNetworkConfig = getOrCreateAnvilEthConfig(deployer);
    } else if (block.chainid == 1706707152) {
      activeNetworkConfig = getOrCreateStatusDevnetEthConfig(deployer);
    } else {
      revert DeploymentConfig_NoConfigForChain(block.chainid);
    }
  }

  function getOrCreateAnvilEthConfig(address _deployer) public returns (NetworkConfig memory) {
    return
      NetworkConfig({
        deployer: _deployer,
        l2MessageService: address(new L2MessageServiceMock()),
        l1ETHBridge: makeAddr("l1ETHBridge")
      });
  }

  function getOrCreateStatusDevnetEthConfig(address _deployer) public returns (NetworkConfig memory) {
    return
      NetworkConfig({
        deployer: _deployer,
        l2MessageService: L2_MESSAGE_SERVICE_ADDRESS_DEVNET,
        l1ETHBridge: L1_ETH_BRIDGE_ADDRESS_HOODI
      });
  }

  // This function is a hack to have it excluded by `forge coverage` until
  // https://github.com/foundry-rs/foundry/issues/2988 is fixed.
  // See: https://github.com/foundry-rs/foundry/issues/2988#issuecomment-1437784542
  // for more info.
  // solhint-disable-next-line
  function test() public {}
}
