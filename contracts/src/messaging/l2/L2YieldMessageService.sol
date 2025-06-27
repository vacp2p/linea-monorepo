// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import { L2MessageServiceBase } from "./L2MessageServiceBase.sol";

contract L2YieldMessageService is L2MessageServiceBase {
  error L2YieldMessageService__InvalidValue();

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  /**
   * @notice Initializes underlying message service dependencies.
   * @param _rateLimitPeriod The period to rate limit against.
   * @param _rateLimitAmount The limit allowed for withdrawing the period.
   * @param _defaultAdmin The account to be given DEFAULT_ADMIN_ROLE on initialization.
   * @param _roleAddresses The list of addresses to grant roles to.
   * @param _pauseTypeRoles The list of pause type roles.
   * @param _unpauseTypeRoles The list of unpause type roles.
   */
  function initialize(
    uint256 _rateLimitPeriod,
    uint256 _rateLimitAmount,
    address _defaultAdmin,
    RoleAddress[] calldata _roleAddresses,
    PauseTypeRole[] calldata _pauseTypeRoles,
    PauseTypeRole[] calldata _unpauseTypeRoles
  ) external initializer {
    __L2MessageService_init(
      _rateLimitPeriod,
      _rateLimitAmount,
      _defaultAdmin,
      _roleAddresses,
      _pauseTypeRoles,
      _unpauseTypeRoles
    );
  }

  function _claimMessage(
    address _from,
    address _to,
    uint256 _fee,
    uint256 _value,
    bytes calldata _calldata,
    uint256 _nonce
  ) internal override {
    if (_value > 0) {
      revert L2YieldMessageService__InvalidValue();
    }

    super._claimMessage(_from, _to, _fee, _value, _calldata, _nonce);
  }

  function _sendMessage(address _to, uint256 _fee, bytes calldata _calldata) internal override {
    if (msg.value > 0) {
      revert L2YieldMessageService__InvalidValue();
    }

    super._sendMessage(_to, _fee, _calldata);
  }
}
