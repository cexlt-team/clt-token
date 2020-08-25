# CLT

## Inheritance

+ OpenZeppelin's ERC20
+ OpenZeppelin's SafeMath

## Public methods
|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor||uint256|Creates contract and issues all tokens on his address|
|totalSupply||uint256|Current Token Total|
|balanceOf|address _account|uint256|Token amount in account|
|allowance|address owner, address spender|uint256|Number of tokens that the owner has allowed the spender to withdraw|
|cut|uint256 value|uint256|Value of calculate the quantity to destory during transfer|
|transfer|address to, uint256 value|boolean|From owner address sends value to address|
|approve|address spender, uint256 value|boolean|Give Spender the right to withdraw as much tokens as value|
|transferFrom|address from, address to, uint256 value|boolean|From address sends value to address|
|upAllowance|address spender, uint256 addedValue|boolean|Add the value of the privilege granted through the allowance function|
|downAllowance|address spender, uint256 subtractedValue|boolean|Subtract the value of the privilege granted through the allowance function|
|destroy|uint256 amount||Destroy the token by transferring it to the 0x address|
|destroyFrom|address account, uint256 amount||From address sends value 0x address|