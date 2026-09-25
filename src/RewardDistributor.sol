// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardDistributor {
    mapping(address => uint256) public rewards;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addReward(address user, uint256 amount) public {
        // Разработчик хотел сделать эту функцию только для owner,
        // но забыл написать модификатор 'onlyOwner' или 'internal'!
        rewards[user] += amount;
    }

    function claimReward() external {
        uint256 amount = rewards[msg.sender];
        require(amount > 0, "No rewards");
        rewards[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }

    receive() external payable {}
}
