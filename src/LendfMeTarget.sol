// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract LendfMeTarget {
    mapping(address => uint256) public deposits;
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function supply(uint256 amount) external {
        // Уязвимость: Внешний вызов до обновления состояния
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function getDeposit(address user) external view returns (uint256) {
        return deposits[user];
    }
}
