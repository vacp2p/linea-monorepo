// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { MessageServiceBase } from "../../messaging/MessageServiceBase.sol";
import { IMessageService } from "../../messaging/interfaces/IMessageService.sol";

contract L2ETHBridge is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, MessageServiceBase {
  error L2ETHBridge__ETHTransferFailed();

  /**
   * @notice Disables initializers to prevent reinitialization.
   */
  constructor() {
    _disableInitializers();
  }

  /**
   * @notice Initializes the contract.
   * @param _initialOwner The initial owner of the contract.
   * @param _remoteSender The remote sender address.
   * @param _messageService The L2 MessageService address.
   */
  function initialize(address _initialOwner, address _messageService, address _remoteSender) external initializer {
    __MessageServiceBase_init(_messageService);
    _setRemoteSender(_remoteSender);

    _transferOwnership(_initialOwner);
  }

  /**
   * @notice Sets the remote sender address.
   * @param _remoteSender The L1ETHBridge address.
   */
  function setRemoteSender(address _remoteSender) internal onlyOwner {
    _setRemoteSender(_remoteSender);
  }

  /**
   * @notice Sets the L2MessageService address.
   * @param _messageService The L2 MessageService address.
   */
  function setMessageService(address _messageService) external onlyOwner {
    messageService = IMessageService(_messageService);
  }

  /**
   * @notice Completes the bridge. Callable only by the L2MessageService.
   * @param _to The recipient address.
   * @param _value The amount of ETH to transfer.
   * @param _calldata The calldata to pass to the recipient.
   */
  function completeBridge(
    address _to,
    uint256 _value,
    bytes memory _calldata
  ) external nonReentrant onlyMessagingService() onlyAuthorizedRemoteSender {
    (bool success, ) = _to.call{ value: _value }(_calldata);
    if (!success) {
      revert L2ETHBridge__ETHTransferFailed();
    }
  }

  function _authorizeUpgrade(address) internal view override {
    _checkOwner();
  }
}
