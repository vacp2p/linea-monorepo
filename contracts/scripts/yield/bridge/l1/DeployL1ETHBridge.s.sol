// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { BaseScript } from "../Base.s.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { DeploymentConfig } from "./DeploymentConfig.s.sol";
import { L1ETHBridge } from "../../../../src/bridging/eth/L1ETHBridge.sol";

contract DeployL1ETHBridge is BaseScript {
  function run() public returns (address, L1ETHBridge) {
    DeploymentConfig deploymentConfig = new DeploymentConfig(broadcaster);
    (address deployer, address messageService, address remoteSender, address yieldManager) = deploymentConfig
      .activeNetworkConfig();

    vm.startBroadcast(deployer);

    L1ETHBridge impl = new L1ETHBridge();
    bytes memory initializeData = abi.encodeCall(L1ETHBridge.initialize, (deployer, messageService, remoteSender, yieldManager));

    address proxy = address(new ERC1967Proxy(address(impl), initializeData));

    vm.stopBroadcast();

    return (deployer, L1ETHBridge(proxy));
  }
}

