// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.26;

interface IL1ETHBridge {
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

  event MessageCompleted(
    uint256 indexed messageId
  );

  /**
   * @notice Emitted when the yield manager address is set.
   * @param newYieldManager The indexed new yield manager address.
   * @param oldYieldManager The indexed old yield manager address.
   * @param setBy The indexed address setting the new yield manager address.
   */
  event YieldManagerUpdated(
    address indexed newYieldManager,
    address indexed oldYieldManager,
    address indexed setBy
  );

  error L1ETHBridge__ZeroValueNotAllowed();
  error L1ETHBridge__ZeroAddressNotAllowed();
  error L1ETHBridge__ETHTransferFailed();
  error L1ETHBridge__YieldManagerDepositFailed();

  function setRemoteSender(address _remoteSender) external;

  function setMessageService(address _messageService) external;

  function setYieldManager(address _yieldManager) external;

  function bridgeETH(address _to, bytes memory _calldata) external payable;

  function completeBridge(address _to, uint256 _value, bytes calldata _calldata) external;
}
