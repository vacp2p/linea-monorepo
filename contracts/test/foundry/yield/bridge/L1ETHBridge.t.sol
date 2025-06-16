// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { L1ETHBridge } from "../../../../src/yield/bridge/L1ETHBridge.sol";
import { DeployL1ETHBridge } from "../../../../scripts/yield/bridge/l1/DeployL1ETHBridge.s.sol";
import { IL2ETHBridge } from "../../../../src/yield/bridge/interfaces/IL2ETHBridge.sol";

import { RollupMock } from "./mocks/RollupMock.sol";
import { ETHYieldManagerMock } from "./mocks/ETHYieldManagerMock.sol";

contract L1ETHBridgeTest is Test {
  L1ETHBridge bridge;
  RollupMock messageService;
  ETHYieldManagerMock yieldManager;

  address deployer;
  address remoteSender;
  address user1 = makeAddr("user1");
  address user2 = makeAddr("user2");

  function setUp() public {
    DeployL1ETHBridge script = new DeployL1ETHBridge();
    (deployer, bridge) = script.run();
    messageService = RollupMock(address(bridge.messageService()));
    yieldManager = ETHYieldManagerMock(payable(bridge.yieldManager()));
    remoteSender = bridge.remoteSender();
  }

  function test_setYieldManagerRevertsIfZeroAddress() public {
    vm.prank(deployer);
    vm.expectRevert("L1ETHBridge__ZeroAddressNotAllowed()");
    bridge.setYieldManager(address(0));
  }

  function test_setYieldManagerSetsYieldManager() public {
    vm.prank(deployer);
    address newYieldManager = makeAddr("new-yieldManager");
    bridge.setYieldManager(newYieldManager);
    assertEq(bridge.yieldManager(), newYieldManager);
  }

  function test_setRemoteSenderRevertsIfZeroAddress() public {
    vm.prank(deployer);
    vm.expectRevert("ZeroAddressNotAllowed()");
    bridge.setRemoteSender(address(0));
  }

  function test_setMessageServiceRevertsIfZeroAddress() public {
    vm.prank(deployer);
    vm.expectRevert("L1ETHBridge__ZeroAddressNotAllowed()");
    bridge.setMessageService(address(0));
  }

  function test_setMessageServiceSetsMessageService() public {
    vm.prank(deployer);
    address newMessageService = makeAddr("new-messageService");
    bridge.setMessageService(newMessageService);
    assertEq(address(bridge.messageService()), newMessageService);
  }

  function test_setRemoteSenderSetsRemoteSender() public {
    vm.prank(deployer);
    address newRemoteSender = makeAddr("new-remoteSender");
    bridge.setRemoteSender(newRemoteSender);
    assertEq(bridge.remoteSender(), newRemoteSender);
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

    assertEq(messageService.messagesLength(), 1);

    bytes memory expectedData = abi.encodeWithSelector(
      IL2ETHBridge.completeBridge.selector,
      user2,
      100,
      "test-message"
    );

    RollupMock.Message memory message = messageService.lastMessage();
    assertEq(message.to, remoteSender);
    assertEq(message.fee, 0);
    assertEq(message.value, 0);
    assertEq(message.data, expectedData);
  }
}
