// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ETHYieldManagerMock {
  struct Deposit {
    address from;
    uint256 value;
  }

  Deposit[] public deposits;

  receive() external payable {
    deposits.push(Deposit({ from: msg.sender, value: msg.value }));
  }

  function depositsLength() external view returns (uint256) {
    return deposits.length;
  }

  function lastDeposit() external view returns (Deposit memory) {
    require(deposits.length > 0, "No deposits made");
    return deposits[deposits.length - 1];
  }
}

