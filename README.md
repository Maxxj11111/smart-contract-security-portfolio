# Smart Contract Security Audit Portfolio

Professional smart contract security research: 8 vulnerabilities with executable Proof of Concept exploits, verified on a local chain and Ethereum Mainnet fork.

## Highlights

- 8 vulnerability types (Critical to Medium)
- Mainnet fork testing against a real Uniswap V2 pool (~$49.4M TVL)
- Executable on-chain PoC scripts with transaction hashes
- Foundry-based methodology (forge, anvil, cast)

## Vulnerabilities Covered

| # | Vulnerability | Severity | Test |
|---|---------------|----------|------|
| 1 | Inflation Attack (First Depositor) | Critical | test/InflationAttackTest.sol |
| 2 | Precision Loss (Dust) | High | test/IporPrecisionFinalTest.sol |
| 3 | tx.origin Phishing | High | test/TxOriginRealTest.sol |
| 4 | Reentrancy | Critical | test/ExploitTest.sol |
| 5 | Griefing / DoS | Medium | test/GriefingFinalTest.sol |
| 6 | Reentrant Token (LendfMe-style) | Critical | test/LendfMeAttackTest.sol |
| 7 | Vesting Logic | High | test/VestingExploitTest.sol |
| 8 | Vault Accounting | Medium | test/SimpleVaultExploitTest.sol |

## Quick Start

    forge test

## Mainnet Fork Test

    export MAINNET_RPC="https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
    forge test --match-test testRealProtocolExploit -vvvv

## On-Chain PoC (local Anvil)

    anvil
    forge script script/InflationAttack.s.sol:InflationAttackScript --rpc-url http://localhost:8545 --broadcast -vvvv

## Full Report

See REPORT.md for detailed analysis, results and mitigations.

## Disclaimer

Educational purposes only. Do not use against live protocols without permission.
