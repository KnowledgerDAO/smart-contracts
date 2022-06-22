// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AbstractKnowledgerNFT} from "./nft.abstract.sol";
import {IKnowledgerNFT} from "./nft.interface.sol";
import {Assessment, Content, Purchase} from "./content/content.struct.sol";
import {AssessmentApproved, AssessmentDenied} from "./content/content.constants.sol";
import {Number} from "../utils/number.sol";
import {Address} from "../utils/address.sol";
import {IOwner} from "./owner/owner.interface.sol";
import {IBuyer} from "./buyer/buyer.interface.sol";
import {IReviewer} from "./reviewer/reviewer.interface.sol";
import {IContent} from "./content/content.interface.sol";
import {IPublisher} from "./publisher/publisher.interface.sol";
import {Owner as OwnerContract} from "./owner/owner.sol";
import {Buyer as BuyerContract} from "./buyer/buyer.sol";
import {Reviewer as ReviewerContract} from "./reviewer/reviewer.sol";
import {Content as ContentContract} from "./content/content.sol";
import {Publisher as PublisherContract} from "./publisher/publisher.sol";

/**
 * @title KnowledgerNFT controls and provides the specific transactions that ara available to be used by this contract.
 *
 * @dev You can use this class to manage content published by a creator.
 */
contract KnowledgerNFT is AbstractKnowledgerNFT, IKnowledgerNFT {
    IOwner private owner;
    IPublisher private publisher;
    IReviewer private reviewer;
    IBuyer private buyer;
    IContent private content;

    constructor(address payable[] memory _owners)
        AbstractKnowledgerNFT("Knowledger", "KLDN")
    {
        owner = new OwnerContract(_owners);
        buyer = new BuyerContract(owner);
        publisher = new PublisherContract();
        reviewer = new ReviewerContract();
        content = new ContentContract(reviewer);
    }

    /**
     * @dev See {IKnowledgerNFT-allowPublisher}.
     */
    function allowPublisher(address _publisher) external {
        publisher.allowPublisher(_publisher);
        _grantRole(PUBLISHER_ROLE, msg.sender);
    }

    /**
     * @dev See {IKnowledgerNFT-allowReviewer}.
     */
    function allowReviewer(address _reviewer) external {
        reviewer.allowReviewer(_reviewer);
        _grantRole(REVIEWER_ROLE, msg.sender);
    }

    /**
     * @dev See {IKnowledgerNFT-allowBuyer}.
     */
    function allowBuyer(address _buyer) external {
        buyer.allowBuyer(_buyer);
        _grantRole(BUYER_ROLE, msg.sender);
    }

    /**
     * @dev See {IKnowledgerNFT-disallowPublisher}.
     */
    function disallowPublisher(address _publisher)
        external
        checkCaller(_publisher)
    {
        publisher.disallowPublisher(_publisher);
        _revokeRole(PUBLISHER_ROLE, msg.sender);
    }

    /**
     * @dev See {IKnowledgerNFT-disallowReviewer}.
     */
    function disallowReviewer(address _reviewer)
        external
        checkCaller(_reviewer)
    {
        reviewer.disallowReviewer(_reviewer);
        _revokeRole(REVIEWER_ROLE, msg.sender);
    }

    /**
     * @dev See {IKnowledgerNFT-disallowBuyer}.
     */
    function disallowBuyer(address _buyer) external checkCaller(_buyer) {
        buyer.disallowBuyer(_buyer);
        _revokeRole(BUYER_ROLE, msg.sender);
    }

    /**
     * @dev See {IKnowledgerNFT-proposeContent}.
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
        returns (Content memory)
    {
        uint256 _index = content.proposeContent(
            _publisher,
            _contentURI,
            _tokenType,
            _price,
            _prizePercentage,
            _networkPercentage
        );
        _safeMint(_publisher, _index);

        // TODO: Emit some event
        return content.getContent(_index);
    }

    /**
     * @dev See {IKnowledgerNFT-approveContent}.
     */
    function approveContent(uint256 _tokenId, address payable _reviewer)
        external
        checkApproval(_tokenId, _reviewer)
        returns (bool)
    {
        content.approveContent(_tokenId, _reviewer);

        // TODO: Emit some event

        return true;
    }

    /**
     * @dev See {IKnowledgerNFT-denyContent}.
     */
    function denyContent(
        uint256 _tokenId,
        address payable _reviewer,
        string memory _reason
    ) external checkDenial(_tokenId, _reviewer) returns (bool) {
        content.denyContent(_tokenId, _reviewer, _reason);

        // TODO: Emit some event

        return true;
    }

    /**
     * @dev See {IKnowledgerNFT-getApprovals}.
     */
    function getApprovals(uint256 _tokenId)
        external
        view
        checkExistingToken(_tokenId)
        returns (Assessment[] memory)
    {
        return content.getApprovals(_tokenId);
    }

    /**
     * @dev See {IKnowledgerNFT-getDenials}.
     */
    function getDenials(uint256 _tokenId)
        external
        view
        checkExistingToken(_tokenId)
        returns (Assessment[] memory)
    {
        return content.getDenials(_tokenId);
    }

    /**
     * @dev See {IKnowledgerNFT-buyContent}.
     */
    function buyContent(uint256 _tokenId, address payable _buyer)
        external
        payable
        checkPurchase(_tokenId)
        returns (bool)
    {
        Content memory _content = content.getContent(_tokenId);
        buyer.buyContent(_content, _buyer);

        // TODO: Emit some event

        return true;
    }

    /**
     * @dev See {IKnowledgerNFT-getContent}.
     */
    function getContent(uint256 _tokenId)
        external
        view
        checkExistingToken(_tokenId)
        returns (Content memory)
    {
        return content.getContent(_tokenId);
    }

    /**
     * @dev See {IKnowledgerNFT-getBuyerContents}.
     */
    function getBuyerContents()
        external
        view
        checkBuyerUser
        returns (Content[] memory)
    {
        uint256[] memory _tokenIds = buyer.getTokens(msg.sender);
        Content[] memory _contents = new Content[](0);
        uint256 _count = 0;
        for (uint256 i; i < _tokenIds.length; i++) {
            _contents[_count] = content.getContent(_tokenIds[i]);
            _count++;
        }
        return _contents;
    }

    /**
     * @dev See {IKnowledgerNFT-getReviewerContents}.
     */
    function getReviewerContents()
        external
        view
        checkReviewerUser
        returns (Content[] memory)
    {
        uint256[] memory _tokenIds = reviewer.getTokens(msg.sender);
        Content[] memory _contents = new Content[](0);
        uint256 _count = 0;
        for (uint256 i; i < _tokenIds.length; i++) {
            _contents[_count] = content.getContent(_tokenIds[i]);
            _count++;
        }
        return _contents;
    }

    /**
     * @dev Check if a tokenId exist
     */
    function _checkExistingToken(uint256 _tokenId) private view {
        require(
            bytes(tokenURI(_tokenId)).length == 0,
            "The token informed doesn't exist"
        );
    }

    /**
     * @dev Check if a purchase is valid
     */
    function _checkPurchase(uint256 _tokenId) private view {
        _checkRole(BUYER_ROLE);
        _checkExistingToken(_tokenId);
    }

    /**
     * @dev Check if a tokenId exist
     */
    modifier checkExistingToken(uint256 _tokenId) {
        _checkExistingToken(_tokenId);
        _;
    }

    /**
     * @dev Check if an address is the caller of the transaction
     */
    modifier checkCaller(address _caller) {
        Address.checkCaller(_caller);
        _;
    }

    /**
     * @dev Check if a proposal has the minimum requirements
     */
    modifier checkProposal(
        uint256 _price,
        uint256 _prizePercentage,
        uint256 _networkPercentage
    ) {
        _checkRole(PUBLISHER_ROLE);
        _;
    }

    /**
     * @dev Check if a proposal approval has the minimum requirements
     */
    modifier checkApproval(uint256 _tokenId, address _reviewer) {
        Address.checkCaller(_reviewer);
        _checkRole(REVIEWER_ROLE);
        _checkExistingToken(_tokenId);
        _;
    }

    /**
     * @dev Check if a proposal denial has the minimum requirements
     */
    modifier checkDenial(uint256 _tokenId, address _reviewer) {
        Address.checkCaller(_reviewer);
        _checkRole(REVIEWER_ROLE);
        _checkExistingToken(_tokenId);
        _;
    }

    /**
     * @dev Check if a purchase is valid
     */
    modifier checkPurchase(uint256 _tokenId) {
        _checkPurchase(_tokenId);
        _;
    }

    /**
     * @dev Check if a buyer has authorization to perform some operation
     */
    modifier checkBuyerUser() {
        _checkRole(BUYER_ROLE);
        _;
    }

    /**
     * @dev Check if a reviewer has authorization to perform some operation
     */
    modifier checkReviewerUser() {
        _checkRole(REVIEWER_ROLE);
        _;
    }
}
