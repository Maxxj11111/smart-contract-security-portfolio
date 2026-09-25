// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract StakeHub {
    IERC20 public stakingToken;
    uint256 public constant COOLDOWN_PERIOD = 1 days;
    
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastDepositTime;

    constructor(address _token) {
        stakingToken = IERC20(_token);
    }

    // Функция внесения средств
    function stake(uint256 amount) external {
        stakingToken.transferFrom(msg.sender, address(this), amount);
        
        lastDepositTime[msg.sender] = block.timestamp;
        stakedBalance[msg.sender] += amount;
    }

    // Функция вывода средств (с проверкой кулдауна)
    function unstake(uint256 amount) external {
        require(stakedBalance[msg.sender] >= amount, "Insufficient balance");
        
        // Защита от флэш-лоанов: проверяем, прошел ли 1 день с момента депозита
        require(block.timestamp >= lastDepositTime[msg.sender] + COOLDOWN_PERIOD, "Cooldown not passed");
        
        stakedBalance[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }
}
