// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import { L2MessageService } from "../../messaging/l2/L2MessageService.sol";

contract L2YieldMessageService is L2MessageService {
  error L2YieldMessageService__InvalidValue();

  function claimMessage(
    address _from,
    address _to,
    uint256 _fee,
    uint256 _value,
    address payable _feeRecipient,
    bytes calldata _calldata,
    uint256 _nonce
  ) public override {
    if (_value > 0) {
      revert L2YieldMessageService__InvalidValue();
    }

    super.claimMessage(_from, _to, _fee, _value, _feeRecipient, _calldata, _nonce);
  }
}

