// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.28;

import { IMessageService } from "../../messaging/interfaces/IMessageService.sol";
import { L1MessageService } from "../../messaging/l1/L1MessageService.sol";
import { LineaRollup } from "../../rollup/LineaRollup.sol";

contract YieldRollup is LineaRollup {
  error YieldRollup__L1ETHBridgeNotSet();
  error YieldRollup__L2ETHBridgeNotSet();
  error YieldRollup__InvalidValue();
  error YieldRollup__InvalidRecipient();

  address public l1ETHBridge;
  address public l2ETHBridge;

  /**
   * @notice Sets the L1ETHBridge address.
   * @param _l1ETHBridge The new L1ETHBridge address.
   */
  function setL1ETHBridge(address _l1ETHBridge) public onlyRole(DEFAULT_ADMIN_ROLE) {
    l1ETHBridge = _l1ETHBridge;
  }

  /**
   * @notice Sets the L2ETHBridge address.
   * @param _l2ETHBridge The new L2ETHBridge address.
   */
  function setL2ETHBridge(address _l2ETHBridge) public onlyRole(DEFAULT_ADMIN_ROLE) {
    l2ETHBridge = _l2ETHBridge;
  }

  /**
   * @notice Sends a message. It doesn't allow sending ETH. If the message is sent to the L2ETHBridge, it checks if the sender is the L1ETHBridge.
   * @param _to The recipient of the message.
   * @param _fee The fee for the message.
   * @param _calldata The calldata for the message.
   */
  function sendMessage(
    address _to,
    uint256 _fee,
    bytes calldata _calldata
  ) public payable override(IMessageService, L1MessageService) {
    if (l1ETHBridge == address(0)) {
      revert YieldRollup__L1ETHBridgeNotSet();
    }

    if (l2ETHBridge == address(0)) {
      revert YieldRollup__L2ETHBridgeNotSet();
    }

    if (msg.value > 0) {
      revert YieldRollup__InvalidValue();
    }

    if (_to == l2ETHBridge && msg.sender != l1ETHBridge) {
      revert YieldRollup__InvalidRecipient();
    }

    super.sendMessage(_to, _fee, _calldata);
  }
}
