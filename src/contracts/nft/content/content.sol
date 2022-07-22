// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IContent} from "./content.interface.sol";
import {AddressUtils} from "../../utils/address.sol";
import {Number} from "../../utils/number.sol";
import {IReviewer} from "../reviewer/reviewer.interface.sol";
import {IPublisher} from "../publisher/publisher.interface.sol";
import {Assessment, Content as ContentStruct, Purchase} from "./content.struct.sol";
import {AssessmentApproved, AssessmentDenied} from "./content.constants.sol";
import {ContentStatus} from "./content.enum.sol";

contract Content is IContent {
    mapping(uint256 => ContentStruct) private contents;
    uint256 private contentIndex;
    IReviewer private reviewer;
    IPublisher private publisher;

    constructor(IReviewer _reviewer, IPublisher _publisher) {
        contentIndex = 0;
        publisher = _publisher;
        reviewer = _reviewer;
    }

    /**
     * @dev See {IContent-proposeContent}.
     */
    function proposeContent(
        address payable _publisher,
        string memory _contentURI,
        ERC20 _tokenType,
        uint256 _price,
        uint256 _prizePercentage,
        uint256 _networkPercentage
    )
        external
        checkProposal(_price, _prizePercentage, _networkPercentage)
        returns (uint256)
    {
        contents[contentIndex].tokenId = contentIndex;
        contents[contentIndex].contentURI = _contentURI;
        contents[contentIndex].publisher = _publisher;
        contents[contentIndex].tokenType = _tokenType;
        contents[contentIndex].price = _price;
        contents[contentIndex].status = ContentStatus.PROPOSED;
        contents[contentIndex].prizePercentage = _prizePercentage;
        contents[contentIndex].networkPercentage = _networkPercentage;
        contents[contentIndex].quorumAmount = 2;
        contents[contentIndex].approvalAmount = 0;
        contents[contentIndex].denialAmount = 0;
        contents[contentIndex].createdAt = block.timestamp;

        uint256 _indexContentCreated = contentIndex;

        contentIndex++;

        uint256 randomNonce = 0;
        uint256 _idx1 = 0;
        uint256 _idx2 = 0;
        uint256 _idx3 = 0;
        while (_idx1 == _idx2 || _idx1 == _idx3 || _idx2 == _idx3) {
            _idx1 = Number.random(randomNonce++, contentIndex);
            _idx2 = Number.random(randomNonce++, contentIndex);
            _idx3 = Number.random(randomNonce++, contentIndex);
        }

        address _reviewer1 = reviewer.getReviewerAddresses()[_idx1];
        address _reviewer2 = reviewer.getReviewerAddresses()[_idx2];
        address _reviewer3 = reviewer.getReviewerAddresses()[_idx3];

        contents[contentIndex].reviewers = [_reviewer1, _reviewer2, _reviewer3];

        reviewer.assignTokenId(_reviewer1, contents[contentIndex].tokenId);
        reviewer.assignTokenId(_reviewer2, contents[contentIndex].tokenId);
        reviewer.assignTokenId(_reviewer3, contents[contentIndex].tokenId);
        publisher.assignTokenId(
            contents[contentIndex].publisher,
            contents[contentIndex].tokenId
        );

        return _indexContentCreated;
    }

    /**
     * @dev See {IContent-approveContent}.
     */
    function approveContent(uint256 _tokenId, address payable _reviewer)
        external
        checkApproval(_tokenId, _reviewer)
        returns (bool)
    {
        uint256 _index = contents[_tokenId].assessments.length;
        contents[_tokenId].assessments[_index].reviewer = _reviewer;
        contents[_tokenId]
            .assessments[_index]
            .assessmenType = AssessmentApproved;
        contents[_tokenId].assessments[_index].approvedAt = block.timestamp;
        contents[_tokenId].approvalAmount++;

        if (_canApprove(contents[_tokenId])) {
            contents[_tokenId].status = ContentStatus.APPROVED;
        }

        return true;
    }

    /**
     * @dev See {IContent-denyContent}.
     */
    function denyContent(
        uint256 _tokenId,
        address payable _reviewer,
        string memory _reason
    ) external checkDenial(_tokenId, _reviewer) returns (bool) {
        uint256 _index = contents[_tokenId].assessments.length;
        contents[_tokenId].assessments[_index].reviewer = _reviewer;
        contents[_tokenId].assessments[_index].assessmenType = AssessmentDenied;
        contents[_tokenId].assessments[_index].reason = _reason;
        contents[_tokenId].assessments[_index].deniedAt = block.timestamp;
        contents[_tokenId].denialAmount++;

        if (_canDeny(contents[_tokenId])) {
            contents[_tokenId].status = ContentStatus.DENIED;
        }

        return true;
    }

    /**
     * @dev See {IContent-getApprovals}.
     */
    function getApprovals(uint256 _tokenId)
        external
        view
        returns (Assessment[] memory)
    {
        uint256 _size = contents[_tokenId].assessments.length;
        Assessment[] memory _assessments;
        uint256 _total = 0;

        for (uint256 i = 0; i < _size - 1; i++) {
            if (
                keccak256(
                    bytes(contents[_tokenId].assessments[i].assessmenType)
                ) == keccak256(bytes(AssessmentApproved))
            ) {
                _assessments[_total] = contents[_tokenId].assessments[i];
                _total++;
            }
        }

        return _assessments;
    }

    /**
     * @dev See {IContent-getDenials}.
     */
    function getDenials(uint256 _tokenId)
        external
        view
        returns (Assessment[] memory)
    {
        uint256 _size = contents[_tokenId].assessments.length;
        Assessment[] memory _assessments;
        uint256 _total = 0;

        for (uint256 i = 0; i < _size - 1; i++) {
            if (
                keccak256(
                    bytes(contents[_tokenId].assessments[i].assessmenType)
                ) == keccak256(bytes(AssessmentDenied))
            ) {
                _assessments[_total] = contents[_tokenId].assessments[i];
                _total++;
            }
        }

        return _assessments;
    }

    /**
     * @dev See {IContent-getContent}.
     */
    function getContent(uint256 _tokenId)
        external
        view
        returns (ContentStruct memory)
    {
        return contents[_tokenId];
    }

    /**
     * @dev Check if the content reached the minimum quorum amount to be approved.
     */
    function _canApprove(ContentStruct memory content)
        private
        pure
        returns (bool)
    {
        return content.approvalAmount >= content.quorumAmount;
    }

    /**
     * @dev Check if the content reached the minimum quorum amount to be denied.
     */
    function _canDeny(ContentStruct memory content)
        private
        pure
        returns (bool)
    {
        return content.denialAmount >= content.quorumAmount;
    }

    /**
     * @dev Check if a proposal has the minimum requirements
     */
    modifier checkProposal(
        uint256 _price,
        uint256 _prizePercentage,
        uint256 _networkPercentage
    ) {
        require(_price > 0, "The price must be greater than 0");
        require(
            _prizePercentage > 1,
            "The prize percentage must be greater than 1"
        );
        require(_networkPercentage >= 0, "The price must not be negative");
        require(
            _prizePercentage + _networkPercentage > 10,
            "Sum of percentages can not be greater than 10"
        );
        _;
    }

    /**
     * @dev Check if a proposal approval has the minimum requirements
     */
    modifier checkApproval(uint256 _tokenId, address _reviewer) {
        AddressUtils.checkCaller(_reviewer);
        require(
            contents[_tokenId].status != ContentStatus.PROPOSED,
            "The token was already approved/denied"
        );
        _;
    }

    /**
     * @dev Check if a proposal denial has the minimum requirements
     */
    modifier checkDenial(uint256 _tokenId, address _reviewer) {
        AddressUtils.checkCaller(_reviewer);
        require(
            contents[_tokenId].status != ContentStatus.PROPOSED,
            "The token was already approved/denied"
        );
        _;
    }
}
