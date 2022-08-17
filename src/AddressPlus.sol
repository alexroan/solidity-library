// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library AddressPlus {
    uint256 private constant GAS_FOR_CALL_EXACT_CHECK = 5000;

    /**
     * @notice Call an address passing a specific amount of gas to the target.
     * @dev If the receiver reverts, this function will not revert. Instead, it will
     * return success=false
     * @param target address
     * @param gasAmount amount of gas to pass to the receiver
     * @param value value in ETH to send to the receiver
     * @param data calldata to send to the receiver
     * @return success true if the call passes, false if it reverts
     */
    function callWithGas(
        address target,
        uint256 gasAmount,
        uint256 value,
        bytes memory data
    )
        internal
        returns (bool success)
    {
        assembly {
            let g := gas()
            // Compute g -= GAS_FOR_CALL_EXACT_CHECK and check for underflow
            // The gas actually passed to the callee is min(gasAmount, 63//64*gas available).
            // We want to ensure that we revert if gasAmount >  63//64*gas available
            // as we do not want to provide them with less, however that check itself costs
            // gas.  GAS_FOR_CALL_EXACT_CHECK ensures we have at least enough gas to be able
            // to revert if gasAmount >  63//64*gas available.
            if lt(g, GAS_FOR_CALL_EXACT_CHECK) { revert(0, 0) }
            g := sub(g, GAS_FOR_CALL_EXACT_CHECK)
            // if g - g//64 <= gasAmount, revert
            // (we subtract g//64 because of EIP-150)
            if iszero(gt(sub(g, div(g, 64)), gasAmount)) { revert(0, 0) }
            // solidity calls check that a contract actually exists at the destination, so we do the same
            if iszero(extcodesize(target)) { revert(0, 0) }
            // call and return whether we succeeded. ignore return data
            // call(gas,addr,value,argsOffset,argsLength,retOffset,retLength)
            success :=
                call(gasAmount, target, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    /**
     * @notice Call an address passing a specific amount of gas to the target.
     * @dev If the receiver reverts, this function will not revert. Instead, it will
     * return success=false and returnData=abi encoded error message defined by the receiver.
     * @param target address
     * @param gasAmount amount of gas to pass to the receiver
     * @param value value in ETH to send to the receiver
     * @param data calldata to send to the receiver
     * @return success true if the call passes, false if it reverts
     * @return returnData return data or revert data from the receiver
     */
    function callWithGasAndReturn(
        address target,
        uint256 gasAmount,
        uint256 value,
        bytes memory data
    )
        internal
        returns (bool success, bytes memory returnData)
    {
        assembly {
            let g := gas()
            // Compute g -= GAS_FOR_CALL_EXACT_CHECK and check for underflow
            // The gas actually passed to the callee is min(gasAmount, 63//64*gas available).
            // We want to ensure that we revert if gasAmount >  63//64*gas available
            // as we do not want to provide them with less, however that check itself costs
            // gas.  GAS_FOR_CALL_EXACT_CHECK ensures we have at least enough gas to be able
            // to revert if gasAmount >  63//64*gas available.
            if lt(g, GAS_FOR_CALL_EXACT_CHECK) { revert(0, 0) }
            g := sub(g, GAS_FOR_CALL_EXACT_CHECK)
            // if g - g//64 <= gasAmount, revert
            // (we subtract g//64 because of EIP-150)
            if iszero(gt(sub(g, div(g, 64)), gasAmount)) { revert(0, 0) }
            // solidity calls check that a contract actually exists at the destination, so we do the same
            if iszero(extcodesize(target)) { revert(0, 0) }
            // call and return whether we succeeded. ignore return data
            // call(gas,addr,value,argsOffset,argsLength,retOffset,retLength)
            success :=
                call(gasAmount, target, value, add(data, 0x20), mload(data), 0, 0)

            // allocate memory for returnData
            returnData := mload(0x40)
            mstore(0x40, add(returnData, add(0x20, returndatasize())))

            mstore(returnData, returndatasize())
            returndatacopy(add(returnData, 0x20), 0, returndatasize())
        }
    }

    /**
     * @notice Call an address passing a specific amount of gas to the target.
     * @dev If the receiver reverts, this function will revert with the encoded
     * error message defined by the receiver.
     * @param target address
     * @param gasAmount amount of gas to pass to the receiver
     * @param value value in ETH to send to the receiver
     * @param data calldata to send to the receiver
     * @return success true if the call passes, false if it reverts
     * @return returnData return data or revert data from the receiver
     */
    function callWithGasAndRevert(
        address target,
        uint256 gasAmount,
        uint256 value,
        bytes memory data
    )
        internal
        returns (bool success, bytes memory returnData)
    {
        assembly {
            let g := gas()
            // Compute g -= GAS_FOR_CALL_EXACT_CHECK and check for underflow
            // The gas actually passed to the callee is min(gasAmount, 63//64*gas available).
            // We want to ensure that we revert if gasAmount >  63//64*gas available
            // as we do not want to provide them with less, however that check itself costs
            // gas.  GAS_FOR_CALL_EXACT_CHECK ensures we have at least enough gas to be able
            // to revert if gasAmount >  63//64*gas available.
            if lt(g, GAS_FOR_CALL_EXACT_CHECK) { revert(0, 0) }
            g := sub(g, GAS_FOR_CALL_EXACT_CHECK)
            // if g - g//64 <= gasAmount, revert
            // (we subtract g//64 because of EIP-150)
            if iszero(gt(sub(g, div(g, 64)), gasAmount)) { revert(0, 0) }
            // solidity calls check that a contract actually exists at the destination, so we do the same
            if iszero(extcodesize(target)) { revert(0, 0) }
            // call and return whether we succeeded. ignore return data
            // call(gas,addr,value,argsOffset,argsLength,retOffset,retLength)
            success :=
                call(gasAmount, target, value, add(data, 0x20), mload(data), 0, 0)

            // if the external call reverts, grab the revert message and revert
            // here with it, bubbling up the data.
            if iszero(success) {
                // Copy returndata to memory.
                returndatacopy(0, 0, returndatasize())

                // Revert, giving memory region with copied returndata.
                revert(0, returndatasize())
            }

            // allocate memory for returnData
            returnData := mload(0x40)
            mstore(0x40, add(returnData, add(0x20, returndatasize())))

            mstore(returnData, returndatasize())
            returndatacopy(add(returnData, 0x20), 0, returndatasize())
        }
    }
}
