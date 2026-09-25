# Security Audit Report - PoC Portfolio

## Executive Summary

8 vulnerabilities reproduced with executable Proof of Concept exploits using Foundry.
Verification levels: local unit tests, on-chain transactions on a local Anvil node,
and Ethereum Mainnet fork against real deployed protocols.

## Findings

### 1. Inflation Attack (First Depositor) - Critical
File: test/InflationAttackTest.sol
Flow: seed 1 wei -> donate 10 ETH via receive() -> victim deposits 5 ETH and gets 0 shares
(integer division) -> attacker redeems 1 share and drains the pool.
Result: victim loses 100% of deposit; attacker profit 15 ETH.
Fix: dead shares to address(0), minimum deposit, or virtual offsets.

### 2. Precision Loss (Dust) - High
File: test/IporPrecisionFinalTest.sol
Flow: deposit 1 wei -> (1 * 1e18) / 2 ether = 0 shares -> redeem reverts, funds locked.
Fix: minimum deposit threshold or virtual offset.

### 3. tx.origin Phishing - High
File: test/TxOriginRealTest.sol
Flow: victim calls malicious contract -> malicious contract passes tx.origin check ->
wallet transfers funds to attacker.
Fix: use msg.sender for authorization.

### 4. Reentrancy - Critical
File: test/ExploitTest.sol
Flow: withdraw() sends ETH before state update -> receive() re-enters withdraw() ->
contract drained recursively.
Fix: checks-effects-interactions, ReentrancyGuard.

### 5. Griefing / DoS - Medium
File: test/GriefingFinalTest.sol
Flow: donation inflates share price -> next depositor rounds to 0 shares -> deposit reverts.
Fix: virtual offsets / dead shares.

### 6. Reentrant Token (LendfMe-style) - Critical
File: test/LendfMeAttackTest.sol
Flow: malicious token hook re-enters supply() during transferFrom -> double counting.
Fix: reentrancy lock, balance-diff accounting.

### 7. Vesting Logic - High
File: test/VestingExploitTest.sol
Flow: missing claim tracking -> claim() called repeatedly -> full balance drained.
Fix: lastClaimTimestamp accrual math.

### 8. Vault Accounting - Medium
File: test/SimpleVaultExploitTest.sol
Flow: withdraw more than internal balance -> panic underflow -> vault locked.
Fix: validated amounts and consistent accounting.

## Mainnet Fork Verification

Test: test/RealProtocolPoC.sol
Network: Ethereum Mainnet (chain id 1), block 19000000, RPC: Alchemy.
Target: Uniswap V2 WETH/USDC 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc
Reserves: ~49.4M USDC / ~19270 WETH, price ~2564 USDC per ETH.
Proves methodology works against real production liquidity.

## On-Chain PoC Transactions (local Anvil)

Deploy:  0x582b344a0dfa5f9ea234c74c3fab11043f8d420489fa59e252aa8d1457ec0e0c
Seed:    0xe8e060efba27631eae5d7254d1e7f835a838084d3aeab542a4c5a6e359c006e2
Inflate: 0x304c0608aab76942937f06725f3fa339001ba3493c30c21ba32670c5e01be00c
Victim:  0xe46a69051461560e887cf60f2f64e2e1e948238e3717b23fb0bb927fcf79d3c1
Drain:   0x3b3cf5f0814a6506a1c6c5db9606fcb335851d39377da2002a8923e54b1bbab4

## How to Reproduce

    forge test
    forge test --match-test testInflationAttack -vvvv
    export MAINNET_RPC="https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
    forge test --match-test testRealProtocolExploit -vvvv

## Disclaimer

Educational purposes only. All exploits executed in controlled environments
(local Anvil, Mainnet fork). Never attack live protocols without permission.
