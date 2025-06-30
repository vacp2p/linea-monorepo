// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { BaseScript } from "../Base.s.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { DeploymentConfig } from "./DeploymentConfig.s.sol";
import { ETHYieldManagerMock } from "../../../../test/foundry/bridging/eth/mocks/ETHYieldManagerMock.sol";

contract DeployDummyYieldManager is BaseScript {
  function run() public returns (address, ETHYieldManagerMock) {
    DeploymentConfig deploymentConfig = new DeploymentConfig(broadcaster);
    (address deployer, address messageService, address remoteSender, address yieldManager) = deploymentConfig
      .activeNetworkConfig();

    vm.startBroadcast(deployer);

    ETHYieldManagerMock impl = new ETHYieldManagerMock();

    vm.stopBroadcast();

    return (deployer, impl);
  }
}

