// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ContentStatus} from "./content.enum.sol";

struct Content {
    /**
     * @dev Unique content id
     */
    uint256 tokenId;
    /**
     * @dev The content URI that will store the content, consequently the NFT.
     */
    string contentURI;
    /**
     * @dev Address of the creator's content.
     */
    address payable publisher;
    /**
     * @dev Address of the contract that the publisher wants to be paid and charge the buyers.
     */
    ERC20 tokenType;
    /**
     * @dev Price of the content that will cost to the buyer.
     */
    uint256 price;
    /**
     * @dev Content status
     */
    ContentStatus status;
    /**
     * @dev The percentage that the publisher is willingness to pay as a bounty to the reviewers.
     */
    uint256 prizePercentage;
    /**
     * @dev The percentage to be paid to the network owners to invest in the platform
     */
    uint256 networkPercentage;
    /**
     * Quorum amount to be reacheble in the approval/denial of the content.
     */
    uint8 quorumAmount;
    /**
     * @dev Amount of approvals
     */
    uint8 approvalAmount;
    /**
     * @dev Amount of rejections
     */
    uint8 denialAmount;
    /**
     * @dev Reviewers that are selected to give theis assessments
     */
    address[] reviewers;
    /**
     * @dev Purchases made and associated to the content
     */
    Purchase[] purchases;
    /**
     * @dev Assessments made and associated to the content
     */
    Assessment[] assessments;
    /**
     * @dev Date when the content was created
     */
    uint256 createdAt;
    /**
     * @dev Date when the content was published
     */
    uint256 publishedAt;
}

struct Assessment {
    /**
     * @dev Address of the reviewer
     */
    address payable reviewer;
    /**
     * @dev Assessment type.
     *
     *  Can be:
     *    - APPROVED
     *    - DENIED
     *
     *  Note: See {nft.constants.sol}
     */
    string assessmenType;
    /**
     * @dev Reason of the rejection
     */
    string reason;
    /**
     * @dev Date when the content was approved
     */
    uint256 approvedAt;
    /**
     * @dev Date when the content was rejected
     */
    uint256 deniedAt;
}

struct Purchase {
    /**
     * @dev Address of the buyer
     */
    address payable buyer;
    /**
     * @dev Price charged in the purchase
     */
    uint256 price;
    /**
     * @dev Date when the content was purchased
     */
    uint256 purchasedAt;
}
