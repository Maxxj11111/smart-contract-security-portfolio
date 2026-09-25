// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract VulnerableVesting {
    IERC20 public token;
    mapping(address => uint256) public allocation; 
    mapping(address => uint256) public claimed;    

    constructor(address _token) {
        token = IERC20(_token);
    }

    // Добавили функцию для назначения аллокации (для админа)
    function setAllocation(address user, uint256 amount) external {
        allocation[user] = amount;
    }

    function claim() external {
        uint256 amountToClaim = allocation[msg.sender];
        require(amountToClaim > 0, "No allocation");

        claimed[msg.sender] += amountToClaim;
        token.transfer(msg.sender, amountToClaim);
    }
}
