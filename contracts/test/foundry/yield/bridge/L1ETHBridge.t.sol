// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { L1ETHBridge } from "../../../../src/yield/bridge/L1ETHBridge.sol";
import { DeployL1ETHBridge } from "../../../../scripts/yield/bridge/l1/DeployL1ETHBridge.s.sol";
import { IL2ETHBridge } from "../../../../src/yield/bridge/interfaces/IL2ETHBridge.sol";

import { RollupMock } from "./mocks/RollupMock.sol";
import { ETHYieldManagerMock } from "./mocks/ETHYieldManagerMock.sol";

contract L1ETHBridgeTest is Test {
  L1ETHBridge bridge;
  RollupMock rollup;
  ETHYieldManagerMock yieldManager;

  address deployer;
  address l2ETHBridge;
  address user1 = makeAddr("user1");
  address user2 = makeAddr("user2");

  function setUp() public {
    DeployL1ETHBridge script = new DeployL1ETHBridge();
    (deployer, bridge) = script.run();
    rollup = RollupMock(bridge.rollup());
    yieldManager = ETHYieldManagerMock(payable(bridge.yieldManager()));
    l2ETHBridge = bridge.l2ETHBridge();
  }
}

contract BridgeETHTest is L1ETHBridgeTest {
  function test_RevertsIfYieldManagerIsNotSet() public {
    vm.prank(deployer);
    bridge.setYieldManager(address(0));

    vm.expectRevert("L1ETHBridge__YieldManagerNotSet()");
    bridge.bridgeETH(address(0), "");
  }

  function test_RevertsIfRollupIsNotSet() public {
    vm.prank(deployer);
    bridge.setRollup(address(0));

    vm.expectRevert("L1ETHBridge__RollupAddressNotSet()");
    bridge.bridgeETH(address(0), "");
  }

  function test_RevertsIfL2ETHBridgeIsNotSet() public {
    vm.prank(deployer);
    bridge.setL2ETHBridge(address(0));

    vm.expectRevert("L1ETHBridge__L2ETHBridgeNotSet()");
    bridge.bridgeETH(address(0), "");
  }

  function test_RevertsIfValueIsZero() public {
    vm.expectRevert("L1ETHBridge__ZeroValue()");
    bridge.bridgeETH(address(0), "");
  }

  function test_FundsAreForwardedToYieldManager() public {
    vm.deal(user1, 100);
    vm.prank(user1);
    bridge.bridgeETH{ value: 100 }(user2, "");

    assertEq(yieldManager.depositsLength(), 1);
    ETHYieldManagerMock.Deposit memory deposit = yieldManager.lastDeposit();
    assertEq(deposit.from, address(bridge));
    assertEq(deposit.value, 100);
    assertEq(address(yieldManager).balance, 100);
  }

  function test_MessagesAreSentToL2ETHBridge() public {
    vm.deal(user1, 100);
    vm.prank(user1);
    bridge.bridgeETH{ value: 100 }(user2, "test-message");

    assertEq(rollup.messagesLength(), 1);

    bytes memory expectedData = abi.encodeWithSelector(
      IL2ETHBridge.completeBridge.selector,
      user2,
      100,
      "test-message"
    );

    RollupMock.Message memory message = rollup.lastMessage();
    assertEq(message.to, l2ETHBridge);
    assertEq(message.fee, 0);
    assertEq(message.value, 0);
    assertEq(message.data, expectedData);
  }
}
