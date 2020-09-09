// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

/// @title CLT - ERC20 token. DeFi Token
/// @notice Increase residual value through token destory when transfer
contract CLT is ERC20 {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;

  string constant tokenName = "Cex token\'s Liquidity Token";
  string constant tokenSymbol = "CLT";
  uint8  constant tokenDecimals = 18;
  uint256 _totalSupply = 101010101010101010101010101;
  uint256 public basePercent = 100;

  constructor() public payable ERC20(tokenName, tokenSymbol) {
    _setupDecimals(tokenDecimals);
    _issue(msg.sender, _totalSupply);
  }

  /// @notice Returns total token supply
  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  /// @notice Returns user balance
  function balanceOf(address owner) public view override returns (uint256) {
    return _balances[owner];
  }

  /// @notice Returns number of tokens that the owner has allowed the spender to withdraw
  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowed[owner][spender];
  }

  /// @notice Returns value of calculate the quantity to destory during transfer
  function cut(uint256 value) public view returns (uint256)  {
    uint256 c = value.add(basePercent);
    uint256 d = c.sub(1);
    uint256 roundValue = d.div(basePercent).mul(basePercent);
    uint256 cutValue = roundValue.mul(basePercent).div(10000);
    return cutValue;
  }

  /// @notice From owner address sends value to address.
  function transfer(address to, uint256 value) public virtual override returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    uint256 tokensToBurn = cut(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn);

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);

    _totalSupply = _totalSupply.sub(tokensToBurn);

    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), tokensToBurn);
    return true;
  }

  /// @notice Give Spender the right to withdraw as much tokens as value
  function approve(address spender, uint256 value) public virtual override returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /** @notice From address sends value to address.
              However, this function can only be performed by a spender 
              who is entitled to withdraw through the aprove function. 
  */
  function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);

    uint256 tokensToBurn = cut(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn);

    _balances[to] = _balances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(tokensToBurn);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), tokensToBurn);

    return true;
  }

  /// @notice Add the value of the privilege granted through the allowance function
  function upAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /// @notice Subtract the value of the privilege granted through the allowance function
  function downAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /// @notice Issue token from 0x address
  function _issue(address account, uint256 amount) internal {
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /// @notice Returns _destory function
  function destroy(uint256 amount) external {
    _destroy(msg.sender, amount);
  }

  /// @notice Destroy the token by transferring it to the 0x address.
  function _destroy(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /** @notice From address sends value 0x address.
              However, this function can only be performed by a spender 
              who is entitled to withdraw through the aprove function. 
  */
  function destroyFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _destroy(account, amount);
  }
}