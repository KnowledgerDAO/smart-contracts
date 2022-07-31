// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IPublisher} from "./publisher.interface.sol";
import {PublisherValue} from "./publisher.struct.sol";

contract Publisher is IPublisher {
    mapping(address => PublisherValue) private publishers;
    address[] private publisherAddresses;
    mapping(address => uint256[]) publisherTokens;

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
        publishers[_publisher].index = publisherAddresses.length - 1;
        publishers[_publisher].exists = true;
    }

    /**
     * @dev See {IPublisher-disallowPublisher}.
     */
    function disallowPublisher(address _publisher) external {
        delete publisherAddresses[publishers[_publisher].index];
        publishers[_publisher].exists = false;
        delete publishers[_publisher];
    }

    /**
     * @dev See {IPublisher-getTokens}.
     */
    function getTokens(address _publisher)
        external
        view
        _checkExistingPublisher(_publisher)
        returns (uint256[] memory)
    {
        require(
            publisherTokens[_publisher].length > 0,
            "This publisher doesn't have any content assigned"
        );
        return publisherTokens[_publisher];
    }

    /**
     * @dev See {IPublisher-assignTokenId}.
     */
    function assignTokenId(address _publisher, uint256 _tokenId)
        external
        _checkExistingPublisher(_publisher)
    {
        publisherTokens[_publisher].push(_tokenId);
    }

    /**
     * @dev Check if a publisher already exists
     */
    function checkExistingPublisher(address _publisher) private view {
        bool exists = publishers[_publisher].exists;
        if (exists && publisherAddresses.length > 0) {
            require(
                publisherAddresses[publishers[_publisher].index] == _publisher,
                "Publisher already exists"
            );
        }
    }

    /**
     * @dev Check if a publisher already exists
     */
    modifier _checkExistingPublisher(address _publisher) {
        checkExistingPublisher(_publisher);
        _;
    }
}
