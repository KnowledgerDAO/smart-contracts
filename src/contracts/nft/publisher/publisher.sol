// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IPublisher} from "./publisher.interface.sol";
import {Address} from "../../utils/address.sol";

contract Publisher is IPublisher {
    mapping(address => uint256) private publishers;
    address[] private publisherAddresses;

    constructor() {
        publisherAddresses = new address[](0);
    }

    /**
     * @dev See {IPublisher-allowPublisher}.
     */
    function allowPublisher(address _publisher)
        external
        _checkExistingPublisher(_publisher)
    {
        publisherAddresses.push(_publisher);
        publishers[_publisher] = publisherAddresses.length - 1;
    }

    /**
     * @dev See {IPublisher-disallowPublisher}.
     */
    function disallowPublisher(address _publisher)
        external
        checkCaller(_publisher)
    {
        delete publisherAddresses[publishers[_publisher]];
        delete publishers[_publisher];
    }

    /**
     * @dev Check if a publisher already exists
     */
    function checkExistingPublisher(address _publisher) private view {
        require(
            publisherAddresses[publishers[_publisher]] == _publisher,
            "Publisher already exists"
        );
        Address.checkCaller(_publisher);
    }

    /**
     * @dev Check if a publisher already exists
     */
    modifier _checkExistingPublisher(address _publisher) {
        checkExistingPublisher(_publisher);
        _;
    }

    /**
     * @dev Check if an address is the caller of the transaction
     */
    modifier checkCaller(address _caller) {
        Address.checkCaller(_caller);
        _;
    }
}
