// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IPublisher {
    /**
     * @dev This method makes possible allow an address be a publisher.
     *
     * @param _publisher Publisher address
     */
    function allowPublisher(address _publisher) external;

    /**
     * @dev This method makes possible disallow an address be a publisher.
     *
     * @param _publisher Publisher address
     */
    function disallowPublisher(address _publisher) external;
}
