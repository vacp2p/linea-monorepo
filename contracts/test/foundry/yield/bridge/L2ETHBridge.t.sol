// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { L2ETHBridge } from "../../../../src/yield/bridge/L2ETHBridge.sol";
import { DeployL2ETHBridge } from "../../../../scripts/yield/bridge/l2/DeployL2ETHBridge.s.sol";
import { RecipientMock } from "./mocks/RecipientMock.sol";
import { L2MessageServiceMock } from "./mocks/L2MessageServiceMock.sol";

contract L2ETHBridgeTest is Test {
  L2ETHBridge bridge;

  address deployer;
  address l1ETHBridge;
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

  function test_RevertsIfMsgSenderIsNotL2MessageService() public {
    l2MessageService.setOriginalSender(l1ETHBridge);

    vm.prank(nonAuthorizedSender);
    vm.expectRevert("CallerIsNotMessageService()");
    bridge.completeBridge(l1ETHBridge, 0, "");
  }

  function test_RevertsIfRemoteSenderIsNotL1ETHBridge() public {
    l2MessageService.setOriginalSender(nonAuthorizedSender);

    vm.prank(address(l2MessageService));
    vm.expectRevert("SenderNotAuthorized()");
    bridge.completeBridge(nonAuthorizedSender, 0, "");
  }

  function test_CompleteBridge() public {
    l2MessageService.setOriginalSender(l1ETHBridge);

    assertEq(recipientMock.lastCallParam(), 0);
    assertEq(address(recipientMock).balance, 0);

    vm.prank(address(l2MessageService));
    bytes memory data = abi.encodeWithSelector(RecipientMock.foo.selector, 77);
    bridge.completeBridge(address(recipientMock), 100, data);

    assertEq(recipientMock.lastCallParam(), 77);
    assertEq(address(recipientMock).balance, 100);
  }
}

