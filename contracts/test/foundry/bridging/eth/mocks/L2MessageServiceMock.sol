// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract L2MessageServiceMock {
  struct Message {
    address to;
    uint256 fee;
    uint256 value;
    bytes data;
  }

  Message[] public messages;

  address public originalSender;

  function setOriginalSender(address _originalSender) external {
    originalSender = _originalSender;
  }

  function sender() external view returns (address) {
    return originalSender;
  }

  function sendMessage(address _to, uint256 _fee, bytes calldata _calldata) external payable {
    messages.push(Message({ to: _to, fee: _fee, value: msg.value, data: _calldata }));
  }

  function messagesLength() external view returns (uint256) {
    return messages.length;
  }

  function lastMessage() external view returns (Message memory) {
    require(messages.length > 0, "No messages made");
    return messages[messages.length - 1];
  }
}
