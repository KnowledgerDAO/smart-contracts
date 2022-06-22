// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IOwner} from "./owner.interface.sol";

contract Owner is IOwner {
    address payable[] private owners;

    constructor(address payable[] memory _owners) {
        owners = _owners;
    }

    /**
     * @dev See {IOwner-getOwners}.
     */
    function getOwners() external view returns (address payable[] memory) {
        return owners;
    }
}
