// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingVault {
    IERC20 public stakingToken;
    address public owner;

    constructor(address _token) {
        stakingToken = IERC20(_token);
        owner = msg.sender;
    }

    // Пользователи вносят токены
    function stake(uint256 amount) external {
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    // Владелец спасает случайно отправленные токены (КРОМЕ stakingToken)
    function rescueToken(address token, address to) external {
        require(msg.sender == owner, "Not owner");
        require(token != address(stakingToken), "Cannot rescue staking token");
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, balance);
    }
}
