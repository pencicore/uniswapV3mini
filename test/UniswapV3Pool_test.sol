// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "remix_tests.sol"; // ⬅️ 必须引入
import "hardhat/console.sol";
import "src/UniswapV3Pool.sol";
import "test/ERC20.sol";
import "test/UniswapV3Pool_testHelper.sol";

// ⬅️ 继承 RemixTest 才能使用 log()
contract UniswapV3Pool_test is UniswapV3Pool_testHelper {

    function beforeEach() public {
        uint160 currentSqrP = 5602277097478614198912276234240;
        int24 currentTick = 85176;

        erc0 = new ERC20(10000 ether, "ETH", "weth");
        erc1 = new ERC20(10000 ether, "USDT", "usdt");
        pool = new UniswapV3Pool(
            address(erc0),
            address(erc1),
            currentSqrP,
            currentTick
        );
    }

    function testMintSuccess() public returns (uint256 poolBalance0, uint256 poolBalance1){
        int24 lowerTick = 84222;
        int24 upperTick = 86129;
        uint128 liquidity = 1517882343751509868544;
        console.log(unicode"===========铸造前===========");
        console.log("user erc0 balance: ", erc0.balanceOf(address(this)));
        console.log("user erc1 balance: ", erc1.balanceOf(address(this)));
        console.log("pool erc0 balance: ", erc0.balanceOf(address(pool)));
        console.log("pool erc1 balance: ", erc1.balanceOf(address(pool)));
        (poolBalance0, poolBalance1) = pool.mint(
            address(this),
            lowerTick,
            upperTick,
            liquidity,
            ""
        );
        console.log(unicode"===========铸造后===========");
        console.log("user erc0 balance: ", erc0.balanceOf(address(this)));
        console.log("user erc1 balance: ", erc1.balanceOf(address(this)));
        console.log("pool erc0 balance: ", erc0.balanceOf(address(pool)));
        console.log("pool erc1 balance: ", erc1.balanceOf(address(pool)));
        Assert.ok(erc0.balanceOf(address(pool))==0.998976618347425280 ether, unicode"铸造后 erc0 balance is wrong");
        Assert.ok(erc1.balanceOf(address(pool))==5000 ether, unicode"铸造后 erc1 balance is wrong");

        bytes32 positionKey = keccak256(
            abi.encodePacked(address(this), lowerTick, upperTick)
        );
        uint128 posLiquidity = pool.positions(positionKey);
        console.log("liquidity: ", liquidity);
        console.log("pos liquidity:", posLiquidity);
        Assert.equal(posLiquidity, liquidity, unicode"铸造后 erc0 balance is wrong");

        (uint160 sqrtPriceX96, int24 tick) = pool.slot0();
        console.log(unicode"sqrt price X96: ", sqrtPriceX96);
        // console.log(unicode"tick: ", tick);
        Assert.equal(sqrtPriceX96, 5602277097478614198912276234240, unicode"sqrt price X96 is wrong");
        Assert.equal(tick, 85176, unicode"tick is wrong");

        console.log(unicode"===========转账后===========");
        (int256 amount0Delta, int256 amount1Delta) = pool.swap(address(this), "");
        console.log("user erc0 balance: ", erc0.balanceOf(address(this)));
        console.log("user erc1 balance: ", erc1.balanceOf(address(this)));
        console.log("pool erc0 balance: ", erc0.balanceOf(address(pool)));
        console.log("pool erc1 balance: ", erc1.balanceOf(address(pool)));
        Assert.equal(amount0Delta, -0.008396714242162444 ether, "invalid ETH out");
        Assert.equal(amount1Delta, 42 ether, "invalid USDC in");
        
        Assert.equal(
            erc0.balanceOf(address(pool)),
            uint256(0.998976618347425280 ether + amount0Delta),
            "invalid pool ETH balance");
        Assert.equal(
            erc1.balanceOf(address(pool)),
            uint256(5000 ether + amount1Delta),
            "invalid pool USDC balance"
        );
    }
}
