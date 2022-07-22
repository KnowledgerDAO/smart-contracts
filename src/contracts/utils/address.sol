// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library AddressUtils {
    /**
     * @dev Check if an address is the caller of the transaction
     */
    function checkCaller(address _caller) internal view {
        require(
            msg.sender == _caller,
            "The caller of this transaction is not authorized to perform this operation"
        );
    }
}
