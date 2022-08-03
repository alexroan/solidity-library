// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract AddressPlusReceiver {
    error CustomRevertMessage(uint256 number);

    event Called(uint256 indexed number);

    function callMe(uint256 number) external {
        emit Called(number);
    }

    function callMeReturn(uint256 number) external pure returns (uint256) {
        return number;
    }

    function callMeRevert(uint256 number) external pure {
        revert CustomRevertMessage(number);
    }
}
