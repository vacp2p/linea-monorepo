// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { L1ETHBridge } from "../../../../src/bridging/eth/L1ETHBridge.sol";
import { DeployL1ETHBridge } from "../../../../scripts/yield/bridge/l1/DeployL1ETHBridge.s.sol";
import { IL2ETHBridge } from "../../../../src/bridging/eth/interfaces/IL2ETHBridge.sol";

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
  address nonAuthorizedSender = makeAddr("nonAuthorizedSender");

  function setUp() public {
    DeployL1ETHBridge script = new DeployL1ETHBridge();
    (deployer, bridge) = script.run();
    messageService = RollupMock(address(bridge.messageService()));
    yieldManager = ETHYieldManagerMock(payable(bridge.yieldManager()));
    remoteSender = bridge.remoteSender();
  }

  function test_setYieldManagerRevertsIfNotOwner() public {
    vm.prank(nonAuthorizedSender);
    vm.expectRevert("Ownable: caller is not the owner");
    bridge.setYieldManager(address(0));
  }

  function test_setYieldManagerRevertsIfZeroAddress() public {
    vm.prank(deployer);
    vm.expectRevert("L1ETHBridge__ZeroAddressNotAllowed()");
    bridge.setYieldManager(address(0));
  }

  function test_setYieldManager() public {
    vm.prank(deployer);
    address newYieldManager = makeAddr("new-yieldManager");
    bridge.setYieldManager(newYieldManager);
    assertEq(bridge.yieldManager(), newYieldManager);
  }

  function test_setRemoteSenderRevertsIfNotOwner() public {
    vm.prank(nonAuthorizedSender);
    vm.expectRevert("Ownable: caller is not the owner");
    bridge.setRemoteSender(address(0));
  }

  function test_setRemoteSenderRevertsIfZeroAddress() public {
    vm.prank(deployer);
    vm.expectRevert("ZeroAddressNotAllowed()");
    bridge.setRemoteSender(address(0));
  }

  function test_setRemoteSender() public {
    vm.prank(deployer);
    address newRemoteSender = makeAddr("new-remoteSender");
    bridge.setRemoteSender(newRemoteSender);
    assertEq(bridge.remoteSender(), newRemoteSender);
  }

  function test_setMessageServiceRevertsIfNotOwner() public {
    vm.prank(nonAuthorizedSender);
    vm.expectRevert("Ownable: caller is not the owner");
    bridge.setMessageService(address(0));
  }

  function test_setMessageServiceRevertsIfZeroAddress() public {
    vm.prank(deployer);
    vm.expectRevert("L1ETHBridge__ZeroAddressNotAllowed()");
    bridge.setMessageService(address(0));
  }

  function test_setMessageService() public {
    vm.prank(deployer);
    address newMessageService = makeAddr("new-messageService");
    bridge.setMessageService(newMessageService);
    assertEq(address(bridge.messageService()), newMessageService);
  }

  function test_BridgeETHRevertsIfValueIsZero() public {
    vm.expectRevert("L1ETHBridge__ZeroValueNotAllowed()");
    bridge.bridgeETH(address(1), "");
  }

  function test_BridgeETHRevertsIfToIsZeroAddress() public {
    vm.expectRevert("L1ETHBridge__ZeroAddressNotAllowed()");
    bridge.bridgeETH{ value: 100 }(address(0), "");
  }

  function test_BridgeETHFundsAreForwardedToYieldManager() public {
    vm.deal(user1, 100);
    vm.prank(user1);
    bridge.bridgeETH{ value: 100 }(user2, "");

    assertEq(yieldManager.depositsLength(), 1);
    ETHYieldManagerMock.Deposit memory deposit = yieldManager.lastDeposit();
    assertEq(deposit.from, address(bridge));
    assertEq(deposit.value, 100);
    assertEq(address(yieldManager).balance, 100);
  }

  function test_ETHBridgeMessagesAreSentToL2ETHBridge() public {
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

  function test_CompleteBridgeRevertsIfMsgSenderIsNotL2MessageService() public {
    vm.prank(nonAuthorizedSender);
    vm.expectRevert("CallerIsNotMessageService()");
    bridge.completeBridge(user1, 0, "");
  }

  function test_CompleteBridgeRevertsIfRemoteSenderIsNotL2ETHBridge() public {
    messageService.setOriginalSender(nonAuthorizedSender);
    vm.prank(address(messageService));
    vm.expectRevert("SenderNotAuthorized()");
    bridge.completeBridge(user1, 0, "");
  }

  function test_CompleteBridge() public {
    assertEq(bridge.nextCompletedMessageId(), 0);
    messageService.setOriginalSender(remoteSender);

    vm.prank(address(messageService));
    bridge.completeBridge(user1, 100, "test-data");

    assertEq(bridge.nextCompletedMessageId(), 1);
    (address to, uint256 value, bytes memory callData) = bridge.completedMessages(0);
    assertEq(to, user1);
    assertEq(value, 100);
    assertEq(callData, "test-data");
  }
}
