// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { IL2ETHBridge } from "./interfaces/IL2ETHBridge.sol";
import { MessageServiceBase } from "../../messaging/MessageServiceBase.sol";
import { IMessageService } from "../../messaging/interfaces/IMessageService.sol";

contract L2ETHBridge is IL2ETHBridge, Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, MessageServiceBase {

  /**
   * @dev Ensures the address is not address(0).
   * @param _addr Address to check.
   */
  modifier nonZeroAddress(address _addr) {
    if (_addr == address(0)) revert L2ETHBridge__ZeroAddressNotAllowed();
    _;
  }

  /**
   * @dev Ensures the amount is not 0.
   * @param _amount amount to check.
   */
  modifier nonZeroAmount(uint256 _amount) {
    if (_amount == 0) revert L2ETHBridge__ZeroValueNotAllowed();
    _;
  }

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
  function setRemoteSender(address _remoteSender) external onlyOwner {
    _setRemoteSender(_remoteSender);
  }

  /**
   * @notice Sets the L2MessageService address.
   * @param _messageService The L2 MessageService address.
   */
  function setMessageService(address _messageService) external onlyOwner nonZeroAddress(_messageService) {
    emit MessageServiceUpdated(_messageService, address(messageService), msg.sender);

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
  ) external nonReentrant onlyMessagingService onlyAuthorizedRemoteSender {
    (bool success, ) = _to.call{ value: _value }(_calldata);
    if (!success) {
      revert L2ETHBridge__ETHTransferFailed();
    }
  }

  /**
   * @notice Bridges ETH to the L1ETHBridge.
   * @param _to The recipient address on the L1.
   * @param _calldata The calldata to be sent to the L1ETHBridge.
   */
  function bridgeETH(
    address _to,
    bytes memory _calldata
  ) external payable nonZeroAmount(msg.value) nonZeroAddress(_to) {
    bytes memory data = abi.encodeWithSelector(IL2ETHBridge.completeBridge.selector, _to, msg.value, _calldata);
    messageService.sendMessage(remoteSender, 0, data);
  }

  function _authorizeUpgrade(address) internal view override {
    _checkOwner();
  }
}
