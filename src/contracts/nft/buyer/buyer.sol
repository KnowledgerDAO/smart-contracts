// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IBuyer} from "./buyer.interface.sol";
import {Content} from "../content/content.struct.sol";
import {ContentStatus} from "../content/content.enum.sol";
import {IOwner} from "../owner/owner.interface.sol";
import {BuyerValue} from "./buyer.struct.sol";

contract Buyer is IBuyer {
    mapping(address => BuyerValue) private buyers;
    address[] private buyerAddresses;
    mapping(address => uint256[]) buyerTokens;

    IOwner owner;

    constructor(IOwner _owner) {
        buyerAddresses = new address[](0);
        owner = _owner;
    }

    /**
     * @dev See {IBuyer-allowBuyer}.
     */
    function allowBuyer(address _buyer) external _checkExistingBuyer(_buyer) {
        buyerAddresses.push(_buyer);
        buyers[_buyer].index = buyerAddresses.length - 1;
        buyers[_buyer].exists = true;
    }

    /**
     * @dev See {IBuyer-disallowBuyer}.
     */
    function disallowBuyer(address _buyer) external checkCaller(_buyer) {
        delete buyerAddresses[buyers[_buyer].index];
        buyers[_buyer].exists = false;
        delete buyers[_buyer];
    }

    /**
     * @dev See {IBuyer-buyContent}.
     */
    function buyContent(Content memory _content, address payable _buyer)
        external
        payable
        _checkPurchase(_content)
        returns (bool)
    {
        uint256 _totalBounty = _content.price *
            (_content.prizePercentage / 100);
        uint256 _totalNetwork = _content.price *
            (_content.networkPercentage / 100);
        uint256 _totalAmount = _content.price - _totalBounty - _totalNetwork;

        _doPurchaseTransfer(
            _content,
            _buyer,
            _totalAmount,
            _totalBounty,
            _totalNetwork
        );

        // TODO: Emit some event

        return true;
    }

    /**
     * @dev See {IBuyer-getTokens}.
     */
    function getTokens(address _buyer)
        external
        view
        _checkExistingBuyer(_buyer)
        returns (uint256[] memory)
    {
        require(
            buyerTokens[_buyer].length > 0,
            "This buyer doesn't have any content assigned"
        );
        return buyerTokens[_buyer];
    }

    /**
     * @dev Make sure that the transfers will be executed succesfully.
     */
    function _doPurchaseTransfer(
        Content memory _content,
        address payable _buyer,
        uint256 _totalToReceive,
        uint256 _totalBounty,
        uint256 _totalNetwork
    ) private {
        // Transfer token from the caller to the publisher
        _content.tokenType.transferFrom(
            _buyer,
            _content.publisher,
            _totalToReceive
        );

        // Transfer token to the owners
        uint256 _amountOwners = owner.getOwners().length;
        uint256 _totalPerOwner = _totalNetwork / _amountOwners;
        for (uint256 i = 0; i < _amountOwners - 1; i++) {
            address _owner = owner.getOwners()[i];
            _content.tokenType.transferFrom(
                _buyer,
                _content.assessments[i].reviewer,
                _totalPerOwner
            );
            _content.tokenType.transferFrom(_buyer, _owner, _totalToReceive);
        }

        // Transfer token to the reviewers that made assessments
        uint256 _size = _content.assessments.length;
        uint256 _totalPerAssessment = _totalBounty / _size;
        for (uint256 i = 0; i < _size - 1; i++) {
            _content.tokenType.transferFrom(
                _buyer,
                _content.assessments[i].reviewer,
                _totalPerAssessment
            );
        }

        // Concatenate the purchase to the content
        uint256 _index = _content.purchases.length;
        _content.purchases[_index].buyer = _buyer;
        _content.purchases[_index].price =
            _totalToReceive +
            _totalBounty +
            _totalNetwork;
        _content.purchases[_index].purchasedAt = block.timestamp;

        assignContent(_buyer, _content.tokenId);
    }

    /**
     * @dev Check if a purchase is valid
     */
    function checkPurchase(Content memory _content)
        private
        pure
    {
        require(
            _content.status == ContentStatus.APPROVED,
            "To buy a content it must to be approved"
        );
    }

    /**
     * @dev Check if a buyer already exists
     */
    function checkExistingBuyer(address _buyer) private view {
        bool exists = buyers[_buyer].exists;
        if (exists && buyerAddresses.length > 0) {
            require(
                buyerAddresses[buyers[_buyer].index] == _buyer,
                "Buyer already exists"
            );
        }
    }

    /**
     * @dev This method assign a content to a buyer.
     *
     * @param _buyer Address of the reviewer
     * @param _tokenId Unique tokenId
     */
    function assignContent(address _buyer, uint256 _tokenId)
        private
        _checkExistingBuyer(_buyer)
    {
        buyerTokens[_buyer].push(_tokenId);
    }

    /**
     * @dev Check if a purchase is valid
     */
    modifier _checkPurchase(Content memory _content) {
        checkPurchase(_content);
        _;
    }

    /**
     * @dev Check if a buyer already exists
     */
    modifier _checkExistingBuyer(address _buyer) {
        checkExistingBuyer(_buyer);
        _;
    }

    /**
     * @dev Check if an address is the caller of the transaction
     */
    modifier checkCaller(address _caller) {
        _;
    }
}
