// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Уязвимый контракт, который выдает кредиты. Он думает, что знает цену ETH.
contract VulnerableOracle {
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public debt;

    // ГЛУПАЯ ЛОГИКА: Контракт думает, что цена ETH равна балансу USDC / балансу ETH в пуле.
    // В реальной жизни это данные с Uniswap.
    function getEthPrice(uint256 poolUsdc, uint256 poolEth) public pure returns (uint256) {
        return poolUsdc / poolEth;
    }

    // Пользователь вносит ETH как залог, получает USDC в долг.
    function borrow(uint256 poolUsdc, uint256 poolEth) external payable {
        require(msg.value > 0, "Need collateral");

        // Контракт проверяет текущую цену
        uint256 price = getEthPrice(poolUsdc, poolEth);
        
        // Выдает кредит на сумму залога * цена
        uint256 loanAmount = msg.value * price;
        
        collateral[msg.sender] += msg.value;
        debt[msg.sender] += loanAmount;

        // Отправляет кредит (в реальности тут будет перевод USDC)
        (bool ok, ) = msg.sender.call{value: loanAmount}("");
        require(ok, "Loan transfer failed");
    }

    receive() external payable {}
}

