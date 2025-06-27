// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import { LineaRollupBase } from "./LineaRollupBase.sol";

contract YieldRollup is LineaRollupBase {
  error YieldRollup__InvalidValue();
  error YieldRollup__InvalidRecipient();

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(InitializationData calldata _initializationData) external initializer {
    __LineaRollup_init(_initializationData);
  }

  /**
   * @notice Sends a message. It doesn't allow sending ETH.
   * @param _to The recipient of the message.
   * @param _fee The fee for the message.
   * @param _calldata The calldata for the message.
   */
  function _sendMessage(
    address _to,
    uint256 _fee,
    bytes calldata _calldata
  ) internal override {
    if (msg.value > 0) {
      revert YieldRollup__InvalidValue();
    }

    super._sendMessage(_to, _fee, _calldata);
  }
}
