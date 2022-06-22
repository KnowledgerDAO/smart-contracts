// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Abstract class which implements some required methods
 * to becomes possible mint and exhange NFTs with URI storage and access control
 *
 * @dev There are some roles that may control the access of some transactions
 * through the class that inherits this abstraction
 */
abstract contract AbstractKnowledgerNFT is
    ERC721,
    ERC721URIStorage,
    AccessControl
{
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 internal constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");
    bytes32 internal constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    bytes32 internal constant BUYER_ROLE = keccak256("BUYER_ROLE");

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri
    ) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
