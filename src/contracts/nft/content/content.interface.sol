// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Assessment, Content as ContentStruct, ProposeContentRequest, Purchase} from "./content.struct.sol";

interface IContent {
    /**
     * @dev This method makes possible to create a content before publishing.
     *
     * @param _request Request data
     *
     * @return {uint256} Returns the index of the struct added.
     */
    function proposeContent(ProposeContentRequest memory _request)
        external
        returns (uint256);

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
     * @dev This method makes possible return the content.
     *
     * @param _tokenId Id of the token
     *
     * @return {ContentStruct} Returns the content, otherwise throws.
     */
    function getContent(uint256 _tokenId)
        external
        view
        returns (ContentStruct memory);
}
