// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SimpleFeeVault {
    IERC20 public asset;
    uint256 public totalShares;
    mapping(address => uint256) public balanceOf;
    uint256 public performanceFee = 1000; // 10%
    address public treasury;

    constructor(address _asset, address _treasury) {
        asset = IERC20(_asset);
        treasury = _treasury;
    }

    function deposit(uint256 assets) external {
        uint256 shares = _convertToShares(assets);
        require(shares > 0, "Zero shares");

        asset.transferFrom(msg.sender, address(this), assets);
        balanceOf[msg.sender] += shares;
        totalShares += shares;
    }

    function withdraw(uint256 shares) external {
        require(balanceOf[msg.sender] >= shares, "Not enough shares");

        // Хук перед выводом (берет комиссию)
        uint256 assets = _convertToAssets(shares);
        _beforeWithdraw(assets, shares);

        balanceOf[msg.sender] -= shares;
        totalShares -= shares;

        // Отправка токенов пользователю
        asset.transfer(msg.sender, assets);
    }

    // Хук, который берет 10% комиссию
    function _beforeWithdraw(uint256 assets, uint256 shares) internal {
        uint256 fee = (assets * performanceFee) / 10000;
        asset.transfer(treasury, fee);
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        if (totalShares == 0) return assets;
        return (assets * totalShares) / asset.balanceOf(address(this));
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        if (totalShares == 0) return 0;
        return (shares * asset.balanceOf(address(this))) / totalShares;
    }
}
