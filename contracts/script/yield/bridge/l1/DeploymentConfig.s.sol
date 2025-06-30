// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { ETHYieldManagerMock } from "../../../../test/foundry/bridging/eth/mocks/ETHYieldManagerMock.sol";
import { RollupMock } from "../../../../test/foundry/bridging/eth/mocks/RollupMock.sol";

contract DeploymentConfig is Script {
  error DeploymentConfig_InvalidDeployerAddress();
  error DeploymentConfig_NoConfigForChain(uint256);

  // solhint-disable-next-line var-name-mixedcase
  address internal LINEA_ROLLUP_ADDRESS_HOLESKY = 0xA12cc7568d08f848869707996dF47877C506466f;

  // solhint-disable-next-line var-name-mixedcase
  address internal L2_ETH_BRIDGE_ADDRESS_DEVNET = 0x0000000000000000000000000000000000000001;

  // solhint-disable-next-line var-name-mixedcase
  address internal YIELD_MANAGER_ADDRESS_HOLESKY = 0xCaF71dEe9d59d0095eC37c1FFa7E4b8fD3114Bc2; // ETHYieldManagerMock

  struct NetworkConfig {
    address deployer;
    address messageService;
    address remoteSender;
    address yieldManager;
  }

  NetworkConfig public activeNetworkConfig;

  address private deployer;

  constructor(address _broadcaster) {
    if (_broadcaster == address(0)) revert DeploymentConfig_InvalidDeployerAddress();
    deployer = _broadcaster;
    if (block.chainid == 31_337) {
      activeNetworkConfig = getOrCreateAnvilEthConfig(deployer);
    } else if (block.chainid == 17_000) {
      activeNetworkConfig = getOrCreateHoleskyEthConfig(deployer);
    } else {
      revert DeploymentConfig_NoConfigForChain(block.chainid);
    }
  }

  function getOrCreateAnvilEthConfig(address _deployer) public returns (NetworkConfig memory) {
    ETHYieldManagerMock yieldManager = new ETHYieldManagerMock();
    RollupMock rollupMock = new RollupMock();

    return
      NetworkConfig({
        deployer: _deployer,
        messageService: address(rollupMock),
        remoteSender: makeAddr("remoteSender"),
        yieldManager: address(yieldManager)
      });
  }

  function getOrCreateHoleskyEthConfig(address _deployer) public returns (NetworkConfig memory) {
    return
      NetworkConfig({
        deployer: _deployer,
        messageService: LINEA_ROLLUP_ADDRESS_HOLESKY,
        remoteSender: L2_ETH_BRIDGE_ADDRESS_DEVNET,
        yieldManager: YIELD_MANAGER_ADDRESS_HOLESKY
      });
  }

  // This function is a hack to have it excluded by `forge coverage` until
  // https://github.com/foundry-rs/foundry/issues/2988 is fixed.
  // See: https://github.com/foundry-rs/foundry/issues/2988#issuecomment-1437784542
  // for more info.
  // solhint-disable-next-line
  function test() public {}
}
