// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test, console } from "forge-std/Test.sol";
import { L2ETHBridge } from "../../../../src/bridging/eth/L2ETHBridge.sol";
import { DeployL2ETHBridge } from "../../../../script/yield/bridge/l2/DeployL2ETHBridge.s.sol";
import { RecipientMock } from "./mocks/RecipientMock.sol";
import { L2MessageServiceMock } from "./mocks/L2MessageServiceMock.sol";
import { IL1ETHBridge } from "../../../../src/bridging/eth/interfaces/IL1ETHBridge.sol";

contract L2ETHBridgeTest is Test {
  L2ETHBridge bridge;

  address deployer;
  address l1ETHBridge;
  address user1 = makeAddr("user1");
  address user2 = makeAddr("user2");
  address nonAuthorizedSender = makeAddr("nonAuthorizedSender");
  L2MessageServiceMock l2MessageService;

  RecipientMock recipientMock;

  function setUp() public {
    DeployL2ETHBridge script = new DeployL2ETHBridge();
    (deployer, bridge) = script.run();
    l1ETHBridge = bridge.remoteSender();
    l2MessageService = L2MessageServiceMock(address(bridge.messageService()));
    recipientMock = new RecipientMock();

    vm.deal(address(bridge), 100e18);
  }

  function test_setMessageServiceRevertsIfNotOwner() public {
    vm.prank(nonAuthorizedSender);
    vm.expectRevert("Ownable: caller is not the owner");
    bridge.setMessageService(address(0));
  }

  function test_setMessageServiceRevertsIfZeroAddress() public {
    vm.prank(deployer);
    vm.expectRevert("L2ETHBridge__ZeroAddressNotAllowed()");
    bridge.setMessageService(address(0));
  }

  function test_setMessageService() public {
    address newMessageService = makeAddr("newMessageService");
    vm.prank(deployer);
    bridge.setMessageService(newMessageService);
    assertEq(address(bridge.messageService()), newMessageService);
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
    address newRemoteSender = makeAddr("newRemoteSender");
    vm.prank(deployer);
    bridge.setRemoteSender(newRemoteSender);
    assertEq(bridge.remoteSender(), newRemoteSender);
  }

  function test_CompleteBridgingRevertsIfMsgSenderIsNotL2MessageService() public {
    vm.prank(nonAuthorizedSender);
    vm.expectRevert("CallerIsNotMessageService()");
    bridge.completeBridging(l1ETHBridge, 0, "");
  }

  function test_CompleteBridgingRevertsIfRemoteSenderIsNotL1ETHBridge() public {
    l2MessageService.setOriginalSender(nonAuthorizedSender);

    vm.prank(address(l2MessageService));
    vm.expectRevert("SenderNotAuthorized()");
    bridge.completeBridging(user1, 0, "");
  }

  function test_CompleteBridging() public {
    l2MessageService.setOriginalSender(l1ETHBridge);

    assertEq(recipientMock.lastCallParam(), 0);
    assertEq(address(recipientMock).balance, 0);

    vm.prank(address(l2MessageService));
    bytes memory data = abi.encodeWithSelector(RecipientMock.foo.selector, 77);
    bridge.completeBridging(address(recipientMock), 100, data);

    assertEq(recipientMock.lastCallParam(), 77);
    assertEq(address(recipientMock).balance, 100);
  }

  function test_bridgeETHRevertsIfValueIsZero() public {
    vm.expectRevert("L2ETHBridge__ZeroValueNotAllowed()");
    bridge.bridgeETH(address(recipientMock), "");
  }

  function test_bridgeETHRevertsIfToIsZeroAddress() public {
    vm.expectRevert("L2ETHBridge__ZeroAddressNotAllowed()");
    bridge.bridgeETH{value: 100}(address(0), "");
  }

  function test_ETHBridgeMessagesAreSentToL1ETHBridge() public {
    vm.deal(user1, 100);
    vm.prank(user1);
    bridge.bridgeETH{ value: 100 }(user2, "test-message");

    assertEq(l2MessageService.messagesLength(), 1);

    bytes memory expectedData = abi.encodeWithSelector(
      IL1ETHBridge.completeBridging.selector,
      user2,
      100,
      "test-message"
    );

    L2MessageServiceMock.Message memory message = l2MessageService.lastMessage();
    assertEq(message.to, l1ETHBridge);
    assertEq(message.fee, 0);
    assertEq(message.value, 0);
    assertEq(message.data, expectedData);
  }
}
