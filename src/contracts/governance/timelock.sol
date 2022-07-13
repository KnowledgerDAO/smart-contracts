// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract Timelock is TimelockController {
  /**
   * @dev The parameters below can give us a little brief description about their meaning:
   *
   *  - _minDelay - Is how long you have to wait before executing
   *  - _proposers - Is the list of addresses that can propose
   *  - _executors - Is the list of addresses that can execute
   */
  constructor(
    uint256 _minDelay,
    address[] memory _proposers,
    address[] memory _executors
  ) TimelockController(_minDelay, _proposers, _executors) {
  }
}