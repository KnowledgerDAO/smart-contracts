// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Number {
    /**
     * @dev Generate a random number based on a nonce and in a number to be compared as a module of the result.
     *
     * @return {uint256} Random number
     */
    function random(uint256 _randomNonce, uint256 _modulus)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        _randomNonce
                    )
                )
            ) & _modulus;
    }
}
