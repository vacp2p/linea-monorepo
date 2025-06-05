// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.26;

interface IL2ETHBridge {
  function completeBridge(address _to, uint256 _value, bytes calldata _calldata) external;
}
