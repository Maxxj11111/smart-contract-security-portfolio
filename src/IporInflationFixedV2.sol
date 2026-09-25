// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IporInflationFixedV2 {
    uint256 public totalAssets;
    uint256 public totalShares;
    mapping(address => uint256) public ipTokenBalance;

    uint256 private constant VIRTUAL_SHARES = 1e6;
    uint256 private constant VIRTUAL_ASSETS = 1;

    receive() external payable {
        totalAssets += msg.value;
    }

    function provideLiquidity(address beneficiary) external payable {
        uint256 exchangeRate = ((totalAssets + VIRTUAL_ASSETS) * 1e18) / (totalShares + VIRTUAL_SHARES);
        uint256 ipTokenAmount = (msg.value * 1e18) / exchangeRate;
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
