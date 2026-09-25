// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsecureVault {
    mapping(address => uint256) public balances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // ВНИМАНИЕ: Разработчик забыл проверить, кто вызывает эту функцию!
    function emergencyWithdraw(address to) external {
        uint256 balance = balances[msg.sender];
        (bool success, ) = to.call{value: balance}("");
        require(success, "Transfer failed");
        balances[msg.sender] = 0;
    }
}
