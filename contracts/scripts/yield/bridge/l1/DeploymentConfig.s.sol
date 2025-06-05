// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { ETHYieldManagerMock } from "../../../../test/foundry/yield/bridge/mocks/ETHYieldManagerMock.sol";
import { RollupMock } from "../../../../test/foundry/yield/bridge/mocks/RollupMock.sol";

contract DeploymentConfig is Script {
  error DeploymentConfig_InvalidDeployerAddress();
  error DeploymentConfig_NoConfigForChain(uint256);

  struct NetworkConfig {
    address deployer;
    address rollup;
    address yieldManager;
    address l2ETHBridge;
  }

  NetworkConfig public activeNetworkConfig;

  address private deployer;

  constructor(address _broadcaster) {
    if (_broadcaster == address(0)) revert DeploymentConfig_InvalidDeployerAddress();
    deployer = _broadcaster;
    if (block.chainid == 31_337) {
      activeNetworkConfig = getOrCreateAnvilEthConfig(deployer);
    } else {
      revert DeploymentConfig_NoConfigForChain(block.chainid);
    }
  }

  function getOrCreateAnvilEthConfig(address _deployer) public returns (NetworkConfig memory) {
    ETHYieldManagerMock yieldManager = new ETHYieldManagerMock();
    RollupMock rollup = new RollupMock();

    return
      NetworkConfig({
        deployer: _deployer,
        rollup: address(rollup),
        yieldManager: address(yieldManager),
        l2ETHBridge: makeAddr("l2ETHBridge")
      });
  }

  // This function is a hack to have it excluded by `forge coverage` until
  // https://github.com/foundry-rs/foundry/issues/2988 is fixed.
  // See: https://github.com/foundry-rs/foundry/issues/2988#issuecomment-1437784542
  // for more info.
  // solhint-disable-next-line
  function test() public {}
}
