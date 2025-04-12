// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingProxy {
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalances;

    receive() external payable {}

    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    fallback() external payable {
        // Forward all calls to the implementation contract
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success, "delegatecall failed");
    }
}
