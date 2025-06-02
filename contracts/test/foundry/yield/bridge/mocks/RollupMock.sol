// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IRollup } from "../../../../../src/yield/bridge/interfaces/IRollup.sol";

contract RollupMock is IRollup {
  struct Message {
    address to;
    uint256 fee;
    uint256 value;
    bytes data;
  }

  Message[] public messages;

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

