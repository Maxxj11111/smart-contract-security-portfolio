// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BuggyVault {
    IERC20 public asset;
    uint256 public totalShares;
    mapping(address => uint256) public balanceOf;

    constructor(address _asset) {
        asset = IERC20(_asset);
    }

    function deposit(uint256 assets) external {
        require(assets > 0, "Zero deposit");

        uint256 shares = _convertToShares(assets);
        require(shares > 0, "Zero shares");

        asset.transferFrom(msg.sender, address(this), assets);

        balanceOf[msg.sender] += shares;
        totalShares += shares;
    }

    function redeem(uint256 shares) external {
        require(balanceOf[msg.sender] >= shares, "Not enough shares");

        uint256 assets = _convertToAssets(shares);

        balanceOf[msg.sender] -= shares;
        totalShares -= shares;

        asset.transfer(msg.sender, assets);
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        if (totalShares == 0) return assets;
        return (assets * totalShares) / asset.balanceOf(address(this));
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        if (totalShares == 0) return 0;
        return (shares * asset.balanceOf(address(this)) + totalShares - 1) / totalShares;
    }
}
