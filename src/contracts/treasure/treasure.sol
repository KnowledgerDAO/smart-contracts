// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Treasure is Ownable {
    uint256 private storedAmount;

    event ValueChanged(uint256 newValue);

    /**
     * @dev Retrieve the current amount that treasure is storing
     *
     * @param _newAmount The new amount of tokens to be stored in the treasure
     */
    function store(uint256 _newAmount) public onlyOwner {
        storedAmount = _newAmount;

        emit ValueChanged(_newAmount);
    }

    /**
     * @dev Retrieve the current amount that treasure is storing
     *
     * @return {uint256} Stored amount of tokens
     */
    function retrieve() public view returns (uint256) {
        return storedAmount;
    }
}
