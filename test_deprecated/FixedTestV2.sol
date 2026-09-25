// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/IporInflationFixedMock.sol";

contract FixedTestV2 is Test {
    IporInflationFixedMock ipor;
    address attacker = address(0xBAD);
    address victim = address(0x1);

    function setUp() public {
        ipor = new IporInflationFixedMock();
        vm.deal(attacker, 10 ether);
        vm.deal(victim, 1 ether);
    }

    function testExploit_Fixed() public {
        // Хакер пытается провести атаку
        vm.prank(attacker);
        ipor.provideLiquidity{value: 1}(attacker);
        (bool ok,) = address(ipor).call{value: 2 ether}("");
        require(ok, "Donation failed");

        // Жертва вносит 1 ETH
        vm.prank(victim);
        ipor.provideLiquidity{value: 1 ether}(victim);

        uint256 victimShares = ipor.ipTokenBalance(victim);
        console.log("Victim shares received (Fixed):", victimShares);

        // Теперь жертва получила токены! (Уязвимость устранена)
        assertGt(victimShares, 0, "Victim should have shares");

        // Жертва может вывести свои средства
        vm.prank(victim);
        ipor.redeem(victimShares);
        
        // Жертва вернула почти все свои деньги (с учетом микро-округления 0.999999 ETH)
        assertGt(victim.balance, 0.9 ether, "Victim should get funds back");
        console.log("Victim balance after redeem:", victim.balance);
    }
}
