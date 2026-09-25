// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

contract RealProtocolPoC is Test {
    // Реальные адреса из Mainnet (WETH/USDC pair на Uniswap V2)
    address constant UNISWAP_V2_WETH_USDC = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    IUniswapV2Pair pair;
    IERC20 weth;
    IERC20 usdc;
    
    function setUp() public {
        // Создаем форк Mainnet на недавнем блоке
        string memory rpcUrl = vm.envString("MAINNET_RPC");
        vm.createSelectFork(rpcUrl, 19000000);
        
        pair = IUniswapV2Pair(UNISWAP_V2_WETH_USDC);
        weth = IERC20(WETH);
        usdc = IERC20(USDC);
        
        // Выдаем себе реальные токены через deal (работает только в fork)
        deal(WETH, address(this), 100 ether);
        deal(USDC, address(this), 100000 * 1e6); // 100k USDC
    }
    
    function testRealProtocolExploit() public {
        console.log("=== REAL PROTOCOL POC (MAINNET FORK) ===");
        console.log("Block Number:", block.number);
        console.log("Chain ID:", block.chainid);
        console.log("");
        
        // Получаем реальные резервы пула
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        console.log("Real Pool Reserves:");
        console.log("Reserve0 (USDC):", uint256(reserve0));
        console.log("Reserve1 (WETH):", uint256(reserve1));
        
        // Рассчитываем реальную цену
        uint256 price = (uint256(reserve0) * 1e18) / uint256(reserve1);
        console.log("Real WETH/USDC Price:", price);
        console.log("");
        
        // Демонстрация: мы взаимодействуем с РЕАЛЬНЫМ контрактом Uniswap
        console.log("Our WETH balance:", weth.balanceOf(address(this)));
        console.log("Our USDC balance:", usdc.balanceOf(address(this)));
        
        // В реальном эксплойте здесь была бы манипуляция ценой через flashloan
        // Для демонстрации просто показываем, что мы в реальном Mainnet
        assertTrue(block.chainid == 1, "Should be on Mainnet");
        assertTrue(reserve0 > 0, "Pool should have real reserves");
        
        console.log("");
        console.log("SUCCESS: Interacting with real Mainnet contract!");
    }
}
