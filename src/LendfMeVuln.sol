// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LendfMeVuln {
    mapping(address => uint256) public deposits;
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function supply(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function getMyDeposit() external view returns (uint256) {
        return deposits[msg.sender];
    }
}
