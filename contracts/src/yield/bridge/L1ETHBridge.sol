// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { IRollup } from "./interfaces/IRollup.sol";
import { IL2ETHBridge } from "./interfaces/IL2ETHBridge.sol";

contract L1ETHBridge is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  error L1ETHBridge__ZeroValue();
  error L1ETHBridge__RollupAddressNotSet();
  error L1ETHBridge__YieldManagerNotSet();
  error L1ETHBridge__YieldManagerDepositFailed();
  error L1ETHBridge__L2ETHBridgeNotSet();

  address public rollup;
  address public yieldManager;
  address public l2ETHBridge;

  modifier rollupIsSet() {
    if (rollup == address(0)) {
      revert L1ETHBridge__RollupAddressNotSet();
    }
    _;
  }

  modifier yieldManagerIsSet() {
    if (yieldManager == address(0)) {
      revert L1ETHBridge__YieldManagerNotSet();
    }
    _;
  }

  modifier l2ETHBridgeIsSet() {
    if (l2ETHBridge == address(0)) {
      revert L1ETHBridge__L2ETHBridgeNotSet();
    }
    _;
  }

  /**
   * @notice Initializes the contract.
   * @dev Disables initializers to prevent reinitialization.
   */
  constructor() {
    _disableInitializers();
  }

  /**
   * @notice Initializes the contract.
   * @param _initialOwner The initial owner of the contract.
   * @param _rollup The rollup address.
   * @param _yieldManager The yield manager address.
   * @param _l2ETHBridge The L2ETHBridge address.
   */
  function initialize(
    address _initialOwner,
    address _rollup,
    address _yieldManager,
    address _l2ETHBridge
  ) external initializer {
    _transferOwnership(_initialOwner);
    rollup = _rollup;
    yieldManager = _yieldManager;
    l2ETHBridge = _l2ETHBridge;
  }

  /**
   * @notice Sets the rollup address.
   * @param _rollup The new rollup address.
   */
  function setRollup(address _rollup) external onlyOwner {
    rollup = _rollup;
  }

  /**
   * @notice Sets the yield manager address.
   * @param _yieldManager The new yield manager address.
   */
  function setYieldManager(address _yieldManager) external onlyOwner {
    yieldManager = _yieldManager;
  }

  /**
   * @notice Sets the L2ETHBridge address.
   * @param _l2ETHBridge The new L2ETHBridge address.
   */
  function setL2ETHBridge(address _l2ETHBridge) external onlyOwner {
    l2ETHBridge = _l2ETHBridge;
  }

  /**
   * @notice Bridges ETH to the L2ETHBridge.
   * @param _to The recipient address on the L2.
   * @param _calldata The calldata to be sent to the L2ETHBridge.
   */
  function bridgeETH(
    address _to,
    bytes memory _calldata
  ) external payable rollupIsSet yieldManagerIsSet l2ETHBridgeIsSet {
    if (msg.value == 0) {
      revert L1ETHBridge__ZeroValue();
    }

    (bool success, ) = yieldManager.call{ value: msg.value }("");
    if (!success) {
      revert L1ETHBridge__YieldManagerDepositFailed();
    }

    bytes memory data = abi.encodeWithSelector(IL2ETHBridge.completeBridge.selector, _to, msg.value, _calldata);
    IRollup(rollup).sendMessage(l2ETHBridge, 0, data);
  }

  function _authorizeUpgrade(address) internal view override {
    _checkOwner();
  }
}
