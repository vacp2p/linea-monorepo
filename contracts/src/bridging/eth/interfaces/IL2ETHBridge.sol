// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

interface IL2ETHBridge {
  /**
   * @notice Emitted when the message service address is set.
   * @param newMessageService The indexed new message service address.
   * @param oldMessageService The indexed old message service address.
   * @param setBy The indexed address setting the new message service address.
   */
  event MessageServiceUpdated(
    address indexed newMessageService,
    address indexed oldMessageService,
    address indexed setBy
  );

  error L2ETHBridge__ZeroValueNotAllowed();
  error L2ETHBridge__ZeroAddressNotAllowed();
  error L2ETHBridge__ETHTransferFailed();

  function setRemoteSender(address _remoteSender) external;

  function setMessageService(address _messageService) external;

  function completeBridging(address _to, uint256 _value, bytes calldata _calldata) external;
}
