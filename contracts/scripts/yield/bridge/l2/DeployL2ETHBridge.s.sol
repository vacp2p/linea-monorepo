// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseScript } from "../Base.s.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { DeploymentConfig } from "./DeploymentConfig.s.sol";
import { L2ETHBridge } from "../../../../src/yield/bridge/L2ETHBridge.sol";

contract DeployL2ETHBridge is BaseScript {
  function run() public returns (address, L2ETHBridge) {
    DeploymentConfig deploymentConfig = new DeploymentConfig(broadcaster);
    (address deployer, address l2MessageService, address l1ETHBridge) = deploymentConfig
      .activeNetworkConfig();

    vm.startBroadcast(deployer);

    L2ETHBridge impl = new L2ETHBridge();
    bytes memory initializeData = abi.encodeCall(L2ETHBridge.initialize, (deployer, l2MessageService, l1ETHBridge));

    address proxy = address(new ERC1967Proxy(address(impl), initializeData));

    vm.stopBroadcast();

    return (deployer, L2ETHBridge(proxy));
  }
}

