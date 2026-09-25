// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IporInflationFixedMock {
    uint256 public totalAssets;
    uint256 public totalShares;
    mapping(address => uint256) public ipTokenBalance;

    // Виртуальные доли для защиты от Inflation Attack
    uint256 private constant VIRTUAL_SHARES = 1e6;
    uint256 private constant VIRTUAL_ASSETS = 1;

    receive() external payable {
        totalAssets += msg.value;
    }

    function provideLiquidity(address beneficiary) external payable {
        // ФИКС: Добавляем виртуальные доли. При первом депозите курс не будет 1:1, 
        // он будет занижен, что защищает от округления до нуля.
        uint256 ipTokenAmount = (msg.value * (totalShares + VIRTUAL_SHARES)) / (totalAssets + VIRTUAL_ASSETS);
        
        // ФИКС: Проверка, что пользователь получил > 0 токенов
        require(ipTokenAmount > 0, "Deposit too small");

        totalAssets += msg.value;
        totalShares += ipTokenAmount;
        ipTokenBalance[beneficiary] += ipTokenAmount;
    }

    function redeem(uint256 ipTokenAmount) external {
        require(
            ipTokenAmount > 0 && ipTokenAmount <= ipTokenBalance[msg.sender],
            "CANNOT_REDEEM_IP_TOKEN_TOO_LOW"
        );

        uint256 exchangeRate = ((totalAssets + VIRTUAL_ASSETS) * 1e18) / (totalShares + VIRTUAL_SHARES);
        uint256 amountToReturn = (ipTokenAmount * exchangeRate) / 1e18;

        ipTokenBalance[msg.sender] -= ipTokenAmount;
        totalShares -= ipTokenAmount;
        totalAssets -= amountToReturn;

        payable(msg.sender).transfer(amountToReturn);
    }
}
