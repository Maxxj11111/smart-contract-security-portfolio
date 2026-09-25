// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IporPrecisionMock {
    mapping(address => uint256) public ipTokenBalance;
    mapping(address => uint256) public assetBalance;
    
    // Симулируем exchangeRate. 1 ipToken стоит 2 ETH (в wei)
    uint256 public exchangeRate = 2 ether; 

    receive() external payable {}

    function setBalance(address user) external payable {
        assetBalance[user] = msg.value;
    }

    // Симулируем функцию provideLiquidity из IPOR
    function provideLiquidity(address beneficiary, uint256 assetAmount) external payable {
        // 1. Контракт забирает реальные токены у пользователя
        assetBalance[msg.sender] -= assetAmount;
        
        // 2. Математика IPOR: wadAssetAmount * 1e18 / exchangeRate
        uint256 ipTokenAmount = (assetAmount * 1e18) / exchangeRate;
        
        // 3. Контракт минтит токены пула (даже если ipTokenAmount = 0)
        ipTokenBalance[beneficiary] += ipTokenAmount;
    }

    // Симулируем функцию redeem из IPOR
    function redeem(uint256 ipTokenAmount) external {
        // В IPOR есть жесткая проверка: ipTokenAmount > 0
        require(ipTokenAmount > 0, "CANNOT_REDEEM_IP_TOKEN_TOO_LOW");
        require(ipTokenBalance[msg.sender] >= ipTokenAmount, "Balance too low");

        ipTokenBalance[msg.sender] -= ipTokenAmount;
        assetBalance[msg.sender] += ipTokenAmount * exchangeRate / 1e18;
        
        payable(msg.sender).transfer(ipTokenAmount * exchangeRate / 1e18);
    }
}
