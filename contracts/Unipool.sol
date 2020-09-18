// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/Math.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

contract CLTokenWrapper {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 public UNI = IERC20(0x0F1b7D5E235098e9dA4AE78199021d7938C77AE6);

  uint256 private _totalSupply;
  mapping(address => uint256) private _balances;

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function stake(uint256 amount) public virtual {
    _totalSupply = _totalSupply.add(amount);
    _balances[msg.sender] = _balances[msg.sender].add(amount);
    UNI.safeTransferFrom(msg.sender, address(this), amount);
  }

  function withdraw(uint256 amount) public virtual {
    _totalSupply = _totalSupply.sub(amount);
    _balances[msg.sender] = _balances[msg.sender].sub(amount);
    UNI.safeTransfer(msg.sender, amount);
  }
}

contract Unipool is CLTokenWrapper {
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);

  function stake(uint256 amount) public override {
    require(amount > 0, 'Cannot Stake 0');
    super.stake(amount);
    emit Staked(msg.sender, amount);
  }

  function withdraw(uint256 amount) public override {
    require(amount > 0, "Cannot withdraw 0");
    super.withdraw(amount);
    emit Withdrawn(msg.sender, amount);
  }

  function exit() external {
    withdraw(balanceOf(msg.sender));
  }
}