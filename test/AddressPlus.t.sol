// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./helpers/AddressPlusHelper.sol";
import "./helpers/AddressPlusReceiver.sol";

contract AddressPlusTest_callWithGas is Test {
    AddressPlusHelper internal s_plus;
    AddressPlusReceiver internal s_receiver;

    uint256 internal constant NUMBER = 55;
    uint256 internal constant GAS_AMOUNT = 100000;

    event Called(uint256 indexed number);

    function setUp() public {
        s_plus = new AddressPlusHelper();
        s_receiver = new AddressPlusReceiver();
    }

    function testBasicCallSuccess() public {
        vm.expectEmit(true, false, false, true);
        emit Called(NUMBER);

        (bool success, bytes memory returnData) = s_plus.callWithGas(
            address(s_receiver),
            GAS_AMOUNT,
            0,
            abi.encodeWithSelector(s_receiver.callMe.selector, NUMBER)
        );
        assertTrue(success);
        assertEq(returnData, new bytes(0));
    }

    function testBasicCallGasErrorRevert() public {
        (bool success, bytes memory returnData) = s_plus.callWithGas(
            address(s_receiver),
            100,
            0,
            abi.encodeWithSelector(s_receiver.callMe.selector, NUMBER)
        );
        assertFalse(success);
        assertEq(returnData, new bytes(0));
    }

    function testBasicCallWithReturnDataSuccess() public {
        (bool success, bytes memory returnData) = s_plus.callWithGas(
            address(s_receiver),
            GAS_AMOUNT,
            0,
            abi.encodeWithSelector(s_receiver.callMeReturn.selector, NUMBER)
        );
        assertTrue(success);
        assertEq(returnData, abi.encode(NUMBER));
    }

    function testBasicCallRevertSuccess() public {
        (bool success, bytes memory returnData) = s_plus.callWithGas(
            address(s_receiver),
            GAS_AMOUNT,
            0,
            abi.encodeWithSelector(s_receiver.callMeRevert.selector, NUMBER)
        );
        assertFalse(success);
        assertEq(
            returnData,
            abi.encodeWithSelector(AddressPlusReceiver.CustomRevertMessage.selector, NUMBER)
        );
    }
}
