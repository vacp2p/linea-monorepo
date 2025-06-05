// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract L2MessageServiceMock {
  address public originalSender;

  function setOriginalSender(address _originalSender) external {
    originalSender = _originalSender;
  }

  function sender() external view returns (address) {
    return originalSender;
  }
}

