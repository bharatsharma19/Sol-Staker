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
    address constant USER = 0x587EFaEe4f308aB2795ca35A27Dff8c1dfAF9e3f;

    function setUp() public {
        wrongStakeContract = new StakingContract();
        rightStakeContract = new CleanStakingContract();
        c = new StakingProxy(address(wrongStakeContract));

        // Fund the test user
        vm.deal(USER, 100 ether);
    }

    function testStake() public {
        uint value = 10 ether;
        vm.startPrank(USER);

        (bool success, ) = address(c).call{value: value}(
            abi.encodeWithSignature("stake(uint256)", value)
        );
        assert(success);

        // Get the totalStaked directly from the proxy contract
        uint currentStake = c.totalStaked();
        assertEq(currentStake, value, "Total staked amount should match");

        vm.stopPrank();
    }

    function testUpgradeImplementation() public {
        // Test the wrong implementation first (has bug in unstake)
        uint value = 5 ether;
        vm.startPrank(USER);

        // Stake some ether
        (bool success, ) = address(c).call{value: value}(
            abi.encodeWithSignature("stake(uint256)", value)
        );
        assert(success);

        // Check initial stake
        uint initialTotalStaked = c.totalStaked();
        assertEq(initialTotalStaked, value, "Initial stake should match");

        // Try to unstake (will have incorrect totalStaked due to bug)
        (success, ) = address(c).call(
            abi.encodeWithSignature("unstake(uint256)", value)
        );
        assert(success);

        // Verify the bug - totalStaked should be 0 but is actually value/2
        uint buggyTotalStaked = c.totalStaked();
        assertEq(
            buggyTotalStaked,
            value / 2,
            "Bug in wrongStakeContract should divide by 2"
        );

        // Update the implementation to the fixed version
        vm.stopPrank();

        // Call the updateImplementation function as the owner
        c.updateImplementation(address(rightStakeContract));

        // Try staking and unstaking with the new implementation
        vm.startPrank(USER);
        (success, ) = address(c).call{value: value}(
            abi.encodeWithSignature("stake(uint256)", value)
        );
        assert(success);

        // Check stake with new implementation
        uint newTotalStaked = c.totalStaked();
        assertEq(
            newTotalStaked,
            value + value / 2,
            "New stake should be added to existing value"
        );

        // Unstake with correct implementation
        (success, ) = address(c).call(
            abi.encodeWithSignature("unstake(uint256)", value)
        );
        assert(success);

        // Verify fixed implementation behavior - totalStaked should be reduced by the unstaked amount
        uint fixedTotalStaked = c.totalStaked();
        assertEq(
            fixedTotalStaked,
            value / 2,
            "Fixed implementation should reduce totalStaked correctly"
        );

        vm.stopPrank();
    }
}
