// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { IRollup } from "./interfaces/IRollup.sol";
import { IL2ETHBridge } from "./interfaces/IL2ETHBridge.sol";
import { MessageServiceBase } from "../../messaging/MessageServiceBase.sol";
import { IMessageService } from "../../messaging/interfaces/IMessageService.sol";

contract L1ETHBridge is Initializable, UUPSUpgradeable, OwnableUpgradeable, MessageServiceBase {
  error L1ETHBridge__ZeroValue();
  error L1ETHBridge__ZeroAddressNotAllowed();
  error L1ETHBridge__YieldManagerDepositFailed();

  address public yieldManager;

  /**
   * @notice Disables initializers to prevent reinitialization.
   */
  constructor() {
    _disableInitializers();
  }

  /**
   * @notice Initializes the contract.
   * @param _initialOwner The initial owner of the contract.
   * @param _messageService The message service address (previously rollup).
   * @param _yieldManager The yield manager address.
   * @param _remoteSender The remote sender address (previously l2ETHBridge).
   */
  function initialize(
    address _initialOwner,
    address _messageService,
    address _remoteSender,
    address _yieldManager
  ) external initializer {
    _transferOwnership(_initialOwner);
    __MessageServiceBase_init(_messageService);
    _setRemoteSender(_remoteSender);

    if (_yieldManager == address(0)) {
      revert L1ETHBridge__ZeroAddressNotAllowed();
    }
    yieldManager = _yieldManager;
  }

  /**
   * @notice Sets the message service address.
   * @param _messageService The new message service address.
   */
  function setMessageService(address _messageService) external onlyOwner {
    if (_messageService == address(0)) {
      revert L1ETHBridge__ZeroAddressNotAllowed();
    }

    messageService = IMessageService(_messageService);
  }

  /**
   * @notice Sets the remote sender address.
   * @param _remoteSender The new remote sender address.
   */
  function setRemoteSender(address _remoteSender) external onlyOwner {
    _setRemoteSender(_remoteSender);
  }

  /**
   * @notice Sets the yield manager address.
   * @param _yieldManager The new yield manager address.
   */
  function setYieldManager(address _yieldManager) external onlyOwner {
    if (_yieldManager == address(0)) {
      revert L1ETHBridge__ZeroAddressNotAllowed();
    }

    yieldManager = _yieldManager;
  }

  /**
   * @notice Bridges ETH to the L2ETHBridge.
   * @param _to The recipient address on the L2.
   * @param _calldata The calldata to be sent to the L2ETHBridge.
   */
  function bridgeETH(
    address _to,
    bytes memory _calldata
  ) external payable {
    if (msg.value == 0) {
      revert L1ETHBridge__ZeroValue();
    }

    (bool success, ) = yieldManager.call{ value: msg.value }("");
    if (!success) {
      revert L1ETHBridge__YieldManagerDepositFailed();
    }

    bytes memory data = abi.encodeWithSelector(IL2ETHBridge.completeBridge.selector, _to, msg.value, _calldata);
    messageService.sendMessage(remoteSender, 0, data);
  }

  function _authorizeUpgrade(address) internal view override {
    _checkOwner();
  }
}
