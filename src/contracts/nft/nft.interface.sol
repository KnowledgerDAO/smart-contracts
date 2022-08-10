// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Content, Assessment} from "./content/content.struct.sol";

/**
 * @title Interface responsible to declare the transactions to manage and control a content publishing.
 *
 * @dev The methods allow us to create transactions to propose, approve, deny and buy a content
 * as well as supplies some helpful functions to retrieve data related to the content.
 */
interface IKnowledgerNFT {
    /**
     * @dev This method makes possible allow an address be a publisher.
     *
     * @param _publisher Publisher address
     */
    function allowPublisher(address _publisher) external;

    /**
     * @dev This method makes possible allow an address be a reviewer.
     *
     * @param _reviewer Reviewer address
     */
    function allowReviewer(address _reviewer) external;

    /**
     * @dev This method makes possible allow an address be a buyer.
     *
     * @param _buyer Buyer address
     */
    function allowBuyer(address _buyer) external;

    /**
     * @dev This method makes possible disallow an address be a publisher.
     *
     * @param _publisher Publisher address
     */
    function disallowPublisher(address _publisher) external;

    /**
     * @dev This method makes possible disallow an address be a reviewer.
     *
     * @param _reviewer Reviewer address
     */
    function disallowReviewer(address _reviewer) external;

    /**
     * @dev This method makes possible disallow an address be a buyer.
     *
     * @param _buyer Buyer address
     */
    function disallowBuyer(address _buyer) external;

    /**
     * @dev This method makes possible to create a content before publishing.
     *
     * @param _publisher Address of the creator of the content
     * @param _contentURI URI with the information stored to create the NFT and associate it with the tokenId
     * @param _tokenType Contract address regarding the token type that the publisher wants to charge a buyer
     * @param _price Price of the content
     * @param _prizePercentage The percentage that the publisher is willingness to pay as a bounty to the reviewers
     * @param _networkPercentage The percentage to be paid to the network owners to invest in the platform
     */
    function proposeContent(
        address _publisher,
        string memory _contentURI,
        ERC20 _tokenType,
        uint256 _price,
        uint256 _prizePercentage,
        uint256 _networkPercentage
    ) external;

    /**
     * @dev This method makes possible a reviewer approve some content.
     *
     * @param _tokenId Id of the token
     * @param _reviewer Reviewer address
     *
     * @return {bool} Returns true if the transaction execute successfully, otherwise throws.
     */
    function approveContent(uint256 _tokenId, address payable _reviewer)
        external
        returns (bool);

    /**
     * @dev This method makes possible a reviewer reject/deny some content.
     *
     * @param _tokenId Id of the token
     * @param _reviewer Reviewer address
     * @param _reason Reject reason
     *
     * @return {bool} Returns true if the transaction execute successfully, otherwise throws.
     */
    function denyContent(
        uint256 _tokenId,
        address payable _reviewer,
        string memory _reason
    ) external returns (bool);

    /**
     * @dev This method makes possible retrieve the approval of a content.
     *
     * @param _tokenId Id of the token
     *
     * @return {Assessment[]} Returns a list of the struct called Assessment with its data related to the content
     */
    function getApprovals(uint256 _tokenId)
        external
        view
        returns (Assessment[] memory);

    /**
     * @dev This method makes possible retrieve the denies of a content.
     *
     * @param _tokenId Id of the token
     *
     * @return {Assessment[]} Returns a list of the struct called Assessment with its data related to the content
     */
    function getDenials(uint256 _tokenId)
        external
        view
        returns (Assessment[] memory);

    /**
     * @dev This method makes possible a buyer do a purchase of a content.
     *
     * @param _tokenId Id of the token
     * @param _buyer Buyer address
     *
     * @return {bool} Returns true if the transaction execute successfully, otherwise throws.
     */
    function buyContent(uint256 _tokenId, address payable _buyer)
        external
        payable
        returns (bool);

    /**
     * @dev This method makes possible return the content.
     *
     * @param _tokenId Id of the token
     *
     * @return {Content} Returns the content, otherwise throws.
     */
    function getContent(uint256 _tokenId)
        external
        view
        returns (Content memory);

    /**
     * @dev This method makes possible return the contents related to a publisher.
     *
     * @return {Content[]} Returns the contents, otherwise throws.
     */
    function getPublisherContents(address _publisher)
        external
        view
        returns (Content[] memory);

    /**
     * @dev This method makes possible return the contents related to a buyer.
     *
     * @return {Content[]} Returns the contents, otherwise throws.
     */
    function getBuyerContents() external view returns (Content[] memory);

    /**
     * @dev This method makes possible return the contents related to a reviewer.
     *
     * @return {Content[]} Returns the contents, otherwise throws.
     */
    function getReviewerContents() external view returns (Content[] memory);
}
