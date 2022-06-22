// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Content} from "../content/content.struct.sol";

interface IBuyer {
    /**
     * @dev This method makes possible allow an address be a buyer.
     *
     * @param _buyer Buyer address
     */
    function allowBuyer(address _buyer) external;

    /**
     * @dev This method makes possible disallow an address be a buyer.
     *
     * @param _buyer Buyer address
     */
    function disallowBuyer(address _buyer) external;

    /**
     * @dev This method makes possible a buyer do a purchase of a content.
     *
     * @param _content Content that makes part of the transaction with its token.
     * @param _buyer Buyer address
     *
     * @return {bool} Returns true if the transaction execute successfully, otherwise throws.
     */
    function buyContent(Content memory _content, address payable _buyer)
        external
        payable
        returns (bool);

    /**
     * @dev This method return all tokens linked to a buyer.
     *
     * @return {uint256[] memory} Return all the id of tokens assigned to a buyer.
     */
    function getTokens(address _buyer) external view returns (uint256[] memory);
}
