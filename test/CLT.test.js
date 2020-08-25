const CLT = artifacts.require('CLT');
const { ether, BN, constants, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract('CLT', accounts => {
  let clt;
  const owner = accounts[0];
  const spender = accounts[1];
  const receiver = accounts[2];
  const approveAmount = ether('100');

  before(async () => {
    clt = await CLT.new({ from: owner });
  });

  it('can be created', () => {
    assert.ok(clt);
  });

  it('has the right balance for the contract owner', async () => {
    const supply = ether('101000000');
    const name = "Cex token's Liquidity Token";
    const symbol = 'CLT';
    const decimals = new BN(18);

    const balance = await clt.balanceOf(owner);
    const totalSupply = await clt.totalSupply();
    const tokenName = await clt.name();
    const tokenSymbol = await clt.symbol();
    const tokenDecimals = await clt.decimals();

    expect(totalSupply).to.be.bignumber.equal(supply);
    expect(balance).to.be.bignumber.equal(totalSupply);
    assert.equal(tokenName, name);
    assert.equal(tokenSymbol, symbol);
    expect(tokenDecimals).to.be.bignumber.equal(decimals);
  });

  it('can approve transfer to a spender', async () => {
    const initialAllowance = await clt.allowance(owner, spender);
    await clt.approve(spender, approveAmount);
    const newAllowance = await clt.allowance(owner, spender);
    const validAllowance = web3.utils.toBN(initialAllowance.toString()).add(web3.utils.toBN(approveAmount));

    expect(newAllowance).to.be.bignumber.equal(validAllowance);
  });

  it('transfer token, but 1% destoryed', async () => {
    const onePercent = 500 * 0.01;
    const transferAmount = ether('500');

    const { logs } = await clt.transfer(spender, transferAmount, { from: owner });

    const balance = await clt.balanceOf(owner);
    const newSpenderBalance = await clt.balanceOf(spender);
    const totalSupply = await clt.totalSupply();
    
    const validBalance = web3.utils.toBN(transferAmount).sub(web3.utils.toBN(ether(`${onePercent}`)));
    const validTotal = web3.utils.toBN(balance.toString()).add(web3.utils.toBN(newSpenderBalance.toString()));

    assert.equal(logs.length, 2);
    assert.equal(logs[0].event, 'Transfer');
    assert.equal(logs[0].args.from, owner);
    assert.equal(logs[0].args.to, spender);
    assert.equal(logs[1].event, 'Transfer');
    assert.equal(logs[1].args.from, owner);
    assert.equal(logs[1].args.to, constants.ZERO_ADDRESS);
    assert(logs[0].args.value.eq(validBalance));
    assert(logs[1].args.value.eq(ether(`${onePercent}`)));

    expect(validBalance).to.be.bignumber.equal(newSpenderBalance);
    expect(validTotal).to.be.bignumber.equal(totalSupply);
  });
});