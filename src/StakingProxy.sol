// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingProxy {
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalances;

    address public owner;
    address public implementation;

    receive() external payable {}

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    function updateImplementation(address _newImplementation) external {
        require(msg.sender == owner, "Only owner can update implementation");
        require(
            _newImplementation != address(0),
            "Invalid implementation address"
        );
        implementation = _newImplementation;
    }

    fallback() external payable {
        // Forward all calls to the implementation contract
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success, "delegatecall failed");
    }
}
