// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../../src/AddressPlus.sol";

contract AddressPlusHelper {
    using AddressPlus for address;

    function callWithGas(
        address target,
        uint256 gasAmount,
        uint256 value,
        bytes memory data
    )
        public
        payable
        returns (bool success)
    {
        return target.callWithGas(gasAmount, value, data);
    }

    function callWithGasAndRevert(
        address target,
        uint256 gasAmount,
        uint256 value,
        bytes memory data
    )
        public
        payable
        returns (bool success, bytes memory returnData)
    {
        return target.callWithGasAndRevert(gasAmount, value, data);
    }

    function callWithGasAndReturn(
        address target,
        uint256 gasAmount,
        uint256 value,
        bytes memory data
    )
        public
        payable
        returns (bool success, bytes memory returnData)
    {
        return target.callWithGasAndReturn(gasAmount, value, data);
    }
}
