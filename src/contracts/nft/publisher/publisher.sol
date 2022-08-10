// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IPublisher} from "./publisher.interface.sol";
import {PublisherValue} from "./publisher.struct.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Publisher is IPublisher {
    mapping(address => PublisherValue) public publishers;

    constructor() {}

    /**
     * @dev See {IPublisher-allowPublisher}.
     */
    function allowPublisher(address _publisher)
        external
        _checkExistingPublisher(_publisher)
    {
        publishers[_publisher].publisher = _publisher;
        publishers[_publisher].exists = true;
    }

    /**
     * @dev See {IPublisher-disallowPublisher}.
     */
    function disallowPublisher(address _publisher) external {
        publishers[_publisher].exists = false;
        delete publishers[_publisher];
    }

    /**
     * @dev See {IPublisher-getTokens}.
     */
    function getTokens(address _publisher)
        external
        view
        returns (uint256[] memory)
    {
        bool exists = publishers[_publisher].exists;
        require(
            exists,
            string.concat(
                "This publisher doesn't have any content assigned to the address ",
                Strings.toHexString(uint160(_publisher), 20)
            )
        );

        return publishers[_publisher].tokenIds;
    }

    /**
     * @dev See {IPublisher-assignTokenId}.
     */
    function assignTokenId(address _publisher, uint256 _tokenId) external {
        bool exists = publishers[_publisher].exists;
        require(
            exists,
            string.concat(
                "This publisher doesn't exist with the address ",
                Strings.toHexString(uint160(_publisher), 20)
            )
        );

        publishers[_publisher].tokenIds.push(_tokenId);

        require(
            publishers[_publisher].tokenIds.length > 0,
            "Token assignment was not stored."
        );
    }

    /**
     * @dev Check if a publisher already exists
     */
    function checkExistingPublisher(address _publisher) private view {
        bool exists = publishers[_publisher].exists;
        if (exists) {
            require(!exists, "Publisher already exists");
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
