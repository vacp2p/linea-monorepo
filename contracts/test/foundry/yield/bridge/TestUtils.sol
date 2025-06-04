// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library TestUtils {
  // Helper function to convert address to ascii string
  function _toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(42);
    s[0] = "0";
    s[1] = "x";
    for (uint256 i = 0; i < 20; i++) {
      uint8 b = uint8(uint256(uint160(x)) / (2 ** (8 * (19 - i))));
      uint8 hi = b / 16;
      uint8 lo = b - 16 * hi;
      s[2 + 2 * i] = _char(hi);
      s[3 + 2 * i] = _char(lo);
    }
    return string(s);
  }

  // Helper function to convert byte to char
  function _char(uint8 b) internal pure returns (bytes1 c) {
    if (b < 10) {
      return bytes1(b + 0x30);
    } else {
      return bytes1(b + 0x57);
    }
  }

  // Helper function to convert bytes32 to hex string
  function _toHexString(bytes32 data) internal pure returns (string memory) {
    return _toHexString(abi.encodePacked(data));
  }

  // Helper function to convert bytes to hex string
  function _toHexString(bytes memory data) internal pure returns (string memory) {
    bytes memory hexString = new bytes(data.length * 2 + 2);
    hexString[0] = "0";
    hexString[1] = "x";
    bytes memory hexChars = "0123456789abcdef";
    for (uint256 i = 0; i < data.length; i++) {
      hexString[2 + i * 2] = hexChars[uint8(data[i] >> 4)];
      hexString[3 + i * 2] = hexChars[uint8(data[i] & 0x0f)];
    }
    return string(hexString);
  }
}