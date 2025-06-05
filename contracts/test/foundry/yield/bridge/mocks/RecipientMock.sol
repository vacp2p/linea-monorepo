// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract RecipientMock {
  uint256 public lastCallParam;

  function foo(uint256 _param) external payable {
    lastCallParam = _param;
  }
}
