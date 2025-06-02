// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

interface IRollup {
  function sendMessage(address _to, uint256 _fee, bytes calldata _calldata) external payable;
}

