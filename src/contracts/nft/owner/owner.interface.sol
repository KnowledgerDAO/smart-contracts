// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IOwner {
    /**
     * @dev Fetch the owner addresses.
     */
    function getOwners() external view returns (address payable[] memory);
}
