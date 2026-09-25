// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IporVulnMock {
    mapping(address => uint256) public ipTokenBalance;
    mapping(address => uint256) public assetBalance;
    
    uint256 public exchangeRate = 2 ether; 

    receive() external payable {}

    function setBalance(address user) external payable {
        assetBalance[user] = msg.value;
    }

    function provideLiquidity(address beneficiary, uint256 assetAmount) external payable {
        assetBalance[msg.sender] -= assetAmount;
        uint256 ipTokenAmount = (assetAmount * 1e18) / exchangeRate;
        ipTokenBalance[beneficiary] += ipTokenAmount;
    }

    function redeem(uint256 ipTokenAmount) external {
        require(ipTokenAmount > 0, "CANNOT_REDEEM_IP_TOKEN_TOO_LOW");
        require(ipTokenBalance[msg.sender] >= ipTokenAmount, "Balance too low");

        ipTokenBalance[msg.sender] -= ipTokenAmount;
        assetBalance[msg.sender] += ipTokenAmount * exchangeRate / 1e18;
        
        payable(msg.sender).transfer(ipTokenAmount * exchangeRate / 1e18);
    }
}
