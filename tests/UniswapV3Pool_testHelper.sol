// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "src/interfaces/callback/IUniswapV3MintCallback.sol";
import "src/interfaces/callback/IUniswapV3SwapCallback.sol";
import "src/UniswapV3Pool.sol";
import "tests/ERC20.sol";

contract UniswapV3Pool_testHelper is IUniswapV3MintCallback, IUniswapV3SwapCallback{
    
    event log(string message);

    address user = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    
    UniswapV3Pool public pool;
    ERC20 public erc0;
    ERC20 public erc1;

    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata data) external  {
        erc0.transfer(msg.sender, amount0);
        erc1.transfer(msg.sender, amount1);
        data;
    }
    
    function uniswapV3SwapCallback(
        int256 amount0,
        int256 amount1,
        bytes calldata data // <--- 新行
    ) external {
        if (amount0 > 0) {
            erc0.transfer(msg.sender, uint256(amount0));
        }
        data;
        if (amount1 > 0) {
            erc1.transfer(msg.sender, uint256(amount1));
        }
    }

}