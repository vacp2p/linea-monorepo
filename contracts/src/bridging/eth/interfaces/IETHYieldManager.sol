// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.26;

interface IETHYieldManager {
  function requestWithdrawal(uint256 _amount) external returns (uint256 requestId);

  function claimWithdrawal(uint256 _requestId, uint256 _hintId) external returns (bool success);
}