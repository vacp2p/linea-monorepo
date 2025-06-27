// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { ILineaRollup } from "../../../src/rollup/interfaces/ILineaRollup.sol";
import { IPermissionsManager } from "../../../src/security/access/interfaces/IPermissionsManager.sol";
import { IPauseManager } from "../../../src/security/pausing/interfaces/IPauseManager.sol";
import { IMessageService } from "../../../src/messaging/interfaces/IMessageService.sol";
import { LineaRollup } from "../../../src/rollup/LineaRollup.sol";
import { YieldRollup } from "../../../src/rollup/YieldRollup.sol";
import { TestUtils } from "./TestUtils.sol";

contract YieldRollupTest is Test {
  YieldRollup yieldRollup;

  address user1 = makeAddr("user1");
  address l1ETHBridge = makeAddr("l1ETHBridge");
  address l2ETHBridge = makeAddr("l2ETHBridge");
  address operator = makeAddr("operator");
  address defaultAdmin = makeAddr("defaultAdmin");
  address verifier = makeAddr("verifier");
  address nonAuthorizedAccount = makeAddr("nonAuthorizedAccount");
  address fallbackOperator = makeAddr("fallbackOperator");

  bytes32 VERIFIER_SETTER_ROLE;
  bytes32 VERIFIER_UNSETTER_ROLE;
  bytes32 OPERATOR_ROLE;
  bytes32 DEFAULT_ADMIN_ROLE;

  function setUp() public {
    YieldRollup implementation = new YieldRollup();

    ILineaRollup.InitializationData memory initData;
    initData.initialStateRootHash = bytes32(0x0);
    initData.initialL2BlockNumber = 0;
    initData.genesisTimestamp = block.timestamp;
    initData.defaultVerifier = verifier;
    initData.rateLimitPeriodInSeconds = 86400; // 1 day
    initData.rateLimitAmountInWei = 100 ether;

    initData.roleAddresses = new IPermissionsManager.RoleAddress[](1);
    initData.roleAddresses[0] = IPermissionsManager.RoleAddress({
      addressWithRole: operator,
      role: implementation.OPERATOR_ROLE()
    });

    initData.pauseTypeRoles = new IPauseManager.PauseTypeRole[](0);
    initData.unpauseTypeRoles = new IPauseManager.PauseTypeRole[](0);
    initData.fallbackOperator = fallbackOperator;
    initData.defaultAdmin = defaultAdmin;

    bytes memory initializer = abi.encodeWithSelector(LineaRollup.initialize.selector, initData);

    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initializer);

    yieldRollup = YieldRollup(address(proxy));

    VERIFIER_SETTER_ROLE = yieldRollup.VERIFIER_SETTER_ROLE();
    VERIFIER_UNSETTER_ROLE = yieldRollup.VERIFIER_UNSETTER_ROLE();
    OPERATOR_ROLE = yieldRollup.OPERATOR_ROLE();
    DEFAULT_ADMIN_ROLE = yieldRollup.DEFAULT_ADMIN_ROLE();

    assertEq(yieldRollup.hasRole(DEFAULT_ADMIN_ROLE, defaultAdmin), true, "Default admin not set");
    assertEq(yieldRollup.hasRole(OPERATOR_ROLE, operator), true, "Operator not set");
  }

  function test_RevertsIfInvalidValue() public {
    vm.expectRevert("YieldRollup__InvalidValue()");
    yieldRollup.sendMessage{ value: 1 }(user1, 0, "");
  }

  function test_SendsMessage() public {
    vm.prank(l1ETHBridge);
    vm.expectEmit();
    emit IMessageService.MessageSent(
      l1ETHBridge,
      l2ETHBridge,
      0,
      0,
      1,
      "test-message",
      keccak256(abi.encode(l1ETHBridge, l2ETHBridge, 0, 0, 1, "test-message"))
    );
    yieldRollup.sendMessage(l2ETHBridge, 0, "test-message");

    // Verify message was sent
    assertEq(yieldRollup.nextMessageNumber(), 2); // First message has nonce 1, so next should be 2
  }
}
