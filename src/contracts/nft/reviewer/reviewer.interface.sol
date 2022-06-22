// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Content} from "../content/content.struct.sol";

interface IReviewer {
    /**
     * @dev This method makes possible allow an address be a reviewer.
     *
     * @param _reviewer Reviewer address
     */
    function allowReviewer(address _reviewer) external;

    /**
     * @dev This method makes possible disallow an address be a reviewer.
     *
     * @param _reviewer Reviewer address
     */
    function disallowReviewer(address _reviewer) external;

    /**
     * @dev This method return all reviewer addresses.
     *
     * @return {address[] memory} Return all the reviewer addresses.
     */
    function getReviewerAddresses() external view returns (address[] memory);

    /**
     * @dev This method assign a tokenId to a reviewer.
     *
     * @param _reviewer Address of the reviewer
     * @param _tokenId Unique tokenId
     */
    function assignTokenId(address _reviewer, uint256 _tokenId) external;

    /**
     * @dev This method return all contents linked to a reviewer.
     *
     * @return {uint256[] memory} Return all the if of the tokens assigned to a reviewer.
     */
    function getTokens(address _reviewer)
        external
        view
        returns (uint256[] memory);
}
