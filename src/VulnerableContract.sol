// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract VulnerableDefi {
    mapping(address => uint256) public deposits;
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = deposits[msg.sender];
        require(balance > 0, "No balance");
        
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
        
        deposits[msg.sender] = 0;
    }

    receive() external payable {}
}

