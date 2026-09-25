// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableWallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    // Функция перевода средств
    function transfer(address to, uint256 amount) external {
        // Разработчик использовал tx.origin, думая, что это безопасно
        require(tx.origin == owner, "Not authorized");
        payable(to).transfer(amount);
    }

    receive() external payable {}
}
