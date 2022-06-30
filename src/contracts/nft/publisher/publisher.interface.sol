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

    /**
     * @dev This method return all tokens linked to a publisher.
     *
     * @return {uint256[] memory} Return all the id of tokens assigned to a publisher.
     */
    function getTokens(address _publisher)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev This method assign a tokenId to a publisher.
     *
     * @param _publisher Address of the publisher
     * @param _tokenId Unique tokenId
     */
    function assignTokenId(address _publisher, uint256 _tokenId) external;
}
