// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/StakingContract.sol";
import "src/CleanStakingContract.sol";
import "src/StakingProxy.sol";

contract StakingProxyTestContract is Test {
    StakingContract wrongStakeContract;
    CleanStakingContract rightStakeContract;
    StakingProxy c;

    function setUp() public {
        wrongStakeContract = new StakingContract();
        rightStakeContract = new CleanStakingContract();
        c = new StakingProxy(address(wrongStakeContract));
    }

    function testStake() public {
        uint value = 10 ether;
        vm.deal(0x587EFaEe4f308aB2795ca35A27Dff8c1dfAF9e3f, value);
        vm.prank(0x587EFaEe4f308aB2795ca35A27Dff8c1dfAF9e3f);
        (bool success, ) = address(c).call{value: value}(
            abi.encodeWithSignature("stake(uint256)", value)
        );
        assert(success);

        // Get the totalStaked directly from the proxy contract
        uint currentStake = c.totalStaked();
        console.log("Total staked:", currentStake);
        assert(currentStake == value);
    }
}
