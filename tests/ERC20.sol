// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// import "/src/interfaces/IERC20.sol";
import {IERC20 as TestIERC20} from "/src/interfaces/IERC20.sol";
import "hardhat/console.sol";


contract ERC20 is TestIERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor(uint256 initialSupply, string memory _name, string memory _symbol) {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
        name = _name;
        symbol = _symbol;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Allowance exceeded");
        require(balances[sender] >= amount, "Insufficient balance");

        _transfer(sender, recipient, amount);
        allowances[sender][msg.sender] = currentAllowance - amount;

        emit Approval(sender, msg.sender, allowances[sender][msg.sender]);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Transfer to zero address");

        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }
}
