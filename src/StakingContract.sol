// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

contract StakingContract {
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalances;

    function stake(uint256 amount) public payable {
        require(amount > 0, "Cannot stake 0");
        require(msg.value == amount, "Incorrect amount sent");
        totalStaked += amount;
        stakedBalances[msg.sender] += amount;
    }

    function unstake(uint256 amount) public {
        require(amount > 0, "Cannot unstake 0");
        require(stakedBalances[msg.sender] >= amount, "Insufficient balance");
        stakedBalances[msg.sender] -= amount;
        totalStaked -= amount / 2;
        payable(msg.sender).transfer(amount);
    }
}
