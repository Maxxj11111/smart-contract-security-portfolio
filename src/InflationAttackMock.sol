// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InflationAttackMock {
    // --- State Variables ---
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
    uint256 public totalAssets;

    // --- Events ---
    event Deposit(address indexed user, uint256 assets, uint256 shares);

    receive() external payable {
        // VULNERABILITY: contract accepts ETH directly!
        // This increases totalAssets but DOES NOT mint new shares.
        totalAssets += msg.value;
    }

    // --- Core Logic ---
    
    /**
     * @notice Standard deposit function (ERC-4626 style)
     * shares = (assets * totalSupply) / totalAssets
     */
    function deposit() external payable {
        uint256 assets = msg.value;
        require(assets > 0, "Zero deposit");

        uint256 shares;
        if (totalSupply == 0) {
            // First depositor gets 1:1
            shares = assets;
        } else {
            // Share distribution math
            shares = (assets * totalSupply) / totalAssets;
        }

        // Mint shares
        totalSupply += shares;
        totalAssets += assets;
        balanceOf[msg.sender] += shares;

        emit Deposit(msg.sender, assets, shares);
    }

    /**
     * @notice Withdraw funds
     * assets = (shares * totalAssets) / totalSupply
     */
    function redeem(uint256 shares) external {
        require(shares > 0, "CANNOT_REDEEM_SHARES_TOO_LOW");
        require(balanceOf[msg.sender] >= shares, "Balance too low");

        uint256 assets = (shares * totalAssets) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;
        totalAssets -= assets;

        // FIX: Use .call instead of .transfer and handle return value
        (bool success, ) = payable(msg.sender).call{value: assets}("");
        require(success, "Transfer failed");
    }
}
