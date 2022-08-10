// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

struct PublisherValue {
    address publisher;
    uint256[] tokenIds;
    bool exists;
}