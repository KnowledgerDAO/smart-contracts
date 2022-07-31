// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IReviewer} from "./reviewer.interface.sol";
import {Content} from "../content/content.struct.sol";
import {ReviewerValue} from "./reviewer.struct.sol";

contract Reviewer is IReviewer {
    mapping(address => ReviewerValue) reviewers;
    address[] private reviewerAddresses;
    mapping(address => uint256[]) reviewerTokens;

    constructor() {
        reviewerAddresses = new address[](0);
    }

    /**
     * @dev See {IReviewer-allowReviewer}.
     */
    function allowReviewer(address _reviewer)
        external
        _checkExistingReviewer(_reviewer)
    {
        reviewerAddresses.push(_reviewer);
        reviewers[_reviewer].index = reviewerAddresses.length - 1;
        reviewers[_reviewer].exists = true;
    }

    /**
     * @dev See {IReviewer-disallowReviewer}.
     */
    function disallowReviewer(address _reviewer)
        external
        checkCaller(_reviewer)
    {
        delete reviewerAddresses[reviewers[_reviewer].index];
        reviewers[_reviewer].exists = false;
        delete reviewers[_reviewer];
    }

    /**
     * @dev See {IReviewer-getReviewerAddresses}.
     */
    function getReviewerAddresses() external view returns (address[] memory) {
        return reviewerAddresses;
    }

    /**
     * @dev See {IReviewer-assignTokenId}.
     */
    function assignTokenId(address _reviewer, uint256 _tokenId)
        external
        _checkExistingReviewer(_reviewer)
    {
        reviewerTokens[_reviewer].push(_tokenId);
    }

    /**
     * @dev See {IReviewer-getTokens}.
     */
    function getTokens(address _reviewer)
        external
        view
        _checkExistingReviewer(_reviewer)
        returns (uint256[] memory)
    {
        require(
            reviewerTokens[_reviewer].length > 0,
            "This reviewer doesn't have any token assigned"
        );
        return reviewerTokens[_reviewer];
    }

    /**
     * @dev Check if a reviewer already exists
     */
    function checkExistingReviewer(address _reviewer) private view {
        bool _exists = reviewers[_reviewer].exists;
        if (_exists && reviewerAddresses.length > 0) {
            require(
                reviewerAddresses[reviewers[_reviewer].index] == _reviewer,
                "Reviewer already exists"
            );
        }
    }

    /**
     * @dev Check if a reviewer already exists
     */
    modifier _checkExistingReviewer(address _reviewer) {
        checkExistingReviewer(_reviewer);
        _;
    }

    /**
     * @dev Check if an address is the caller of the transaction
     */
    modifier checkCaller(address _caller) {
        _;
    }
}
