// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Multisend is Ownable {
  using SafeMath for uint256;

  event LogTokenMultiSent(address token, uint256 total);
  event LogGetToken(address token, address receiver, uint256 balance);

  address public receiverAddress;
  uint public txFee = 0.01 ether;

  function getBalance(address _tokenAddress) onlyOwner public {
    address _receiverAddress = getReceiverAddress();
    ERC20 token = ERC20(_tokenAddress);
    uint256 balance = token.balanceOf(address(this));
    token.transfer(_receiverAddress, balance);
    emit LogGetToken(_tokenAddress, _receiverAddress, balance);
  }

  function setReceiverAddress(address _addr) onlyOwner public {
      require(_addr != address(0));
      receiverAddress = _addr;
  }

  function getReceiverAddress() public view returns(address) {
    return receiverAddress;
  }

  function setTxFee(uint _fee) onlyOwner public {
    txFee = _fee;
  }

  function coinSendSameValue(address _tokenAddress, address[] memory _to, uint256 _value) internal {
    uint sendValue = msg.value;
    require(sendValue >= txFee);
    require(_to.length <= 255);

    address from = msg.sender;
    uint256 sendAmount = _to.length.sub(1).mul(_value);

    ERC20 token = ERC20(_tokenAddress);
    for (uint8 i = 1; i < _to.length; i++) {
      token.transferFrom(from, _to[i], _value);
    }

    emit LogTokenMultiSent(_tokenAddress, sendAmount);
  }

  function coinSendDifferentValue(address _tokenAddress, address[] memory _to, uint256[] memory _value) internal {
      uint sendValue = msg.value;
      require(sendValue >= txFee);

      require(_to.length == _value.length);
      require(_to.length <= 255);

      uint256 sendAmount = _value[0];
      ERC20 token = ERC20(_tokenAddress);

      for (uint8 i = 1; i < _to.length; i++) {
        token.transferFrom(msg.sender, _to[i], _value[i]);
      }
      emit LogTokenMultiSent(_tokenAddress, sendAmount);
  }

  function multiSendCoinWithSameValue(address _tokenAddress, address[] memory _to, uint256 _value) payable public {
    coinSendSameValue(_tokenAddress, _to, _value);
  }

  function multiSendCoinWithDifferentValue(address _tokenAddress, address[] memory _to, uint256[] memory _value) payable public {
    coinSendDifferentValue(_tokenAddress, _to, _value);
  }

  function multisendToken(address _tokenAddress, address[] memory _to, uint256[] memory _value) payable public {
    coinSendDifferentValue(_tokenAddress, _to, _value);
  }

  function drop(address _tokenAddress, address[] memory _to, uint256 _value) payable public {
    coinSendSameValue(_tokenAddress, _to, _value);
  }
}