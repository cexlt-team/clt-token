// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

contract CLTReward {
  ERC20 public CLT = ERC20(0xa69f7a10dF90C4D6710588Bc18ad9bF08081f545);

  event MultiTransfer(
    address indexed _from,
    uint indexed _value,
    address _to,
    uint256 _amount
  );

  function multiTransferTightlyPacked(bytes32[] memory _addressesAndAmounts) public payable {
    for (uint i = 0; i < _addressesAndAmounts.length; i++) {
      address to = address(uint160(uint256(_addressesAndAmounts[i])));
      uint256 amount = uint(uint256(_addressesAndAmounts[i]));
      _safeTransfer(to, amount);
      MultiTransfer(msg.sender, msg.value, to, amount);
    }
  }

  function multiTransfer(address[] memory _addresses, uint256[] memory _amounts) public payable {
    for (uint i = 0; i < _addresses.length; i++) {
      _safeTransfer(_addresses[i], _amounts[i]);
      MultiTransfer(msg.sender, msg.value, _addresses[i], _amounts[i]);
    }
  }

  function _safeTransfer(address _to, uint256 _amount) internal {
    require(_to != address(0));
    require(CLT.transferFrom(msg.sender, _to, _amount));
  }

  fallback () external payable {
    revert();
  }

  receive () external payable {
    revert();
  }
}
