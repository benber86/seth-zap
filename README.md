# Synthetix sETH to Curve/Convex Zap

Deposit ETH and borrows then sETH and then deposits sETH into a Curve pool. Possibility to stake on Convex on mainnet.

The same contract can be deployed to Ethereum mainnet and Optimism.

### Deployment addresses

- Ethereum: #
- Optimism: #

### Requirements

- Python 3.9+
- Vyper 0.3.4
- Brownie (latest from the <a href="https://github.com/eth-brownie/brownie">repository</a>)
- Ganache

To install Brownie, use (the currently availabe 1.19 version does not yet support Vyper 0.3.4): `pip install git+git:github.com/eth-brownie/brownie.git#egg=eth-brownie`

### Tests

- Ethereum: `brownie test`
- Optimism: `brownie test --chain op` (require an `optimism-fork` network to be setup with brownie)

### Deployment

There is a deployment scripts in `/script` that can be run as follows, after creating an account in Brownie and updating the account's name in `deploy.py` 

Mainnet: `brownie run scripts/deploy.py`

Optimism: `brownie run scripts/deploy.py --network optimism`

#### Deployment parameters:

| Param          | Description                                      | ETH Value                                   | OP Value                                    |
|----------------|--------------------------------------------------|---------------------------------------------|---------------------------------------------|
| `eth_collateral` | Address of the Synthetix ETH Collateral contract | <a href="https://etherscan.io/address/0x5c8344bcdC38F1aB5EB5C1d4a35DdEeA522B5DfA">0x5c83...5DfA</a> | <a href="https://optimistic.etherscan.io/address/0x308AD16ef90fe7caCb85B784A603CB6E71b1A41a">0x308A...1A41a</a> |
| `seth`           | Address of the sETH token                        | <a href="https://etherscan.io/address/0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb">0x5e74...31cb</a> | <a href="https://optimistic.etherscan.io/address/0xE405de8F52ba7559f9df3C368500B6E6ae6Cee49">0xE405...ee49</a> |
| `curve_pool`     | Address of the ETH/sETH Curve pool               | <a href="https://etherscan.io/address/0xc5424B857f758E906013F3555Dad202e4bdB4567">0xc542...4567</a> | <a href="https://optimistic.etherscan.io/address/0x7Bc5728BC2b59B45a58d9A576E2Ffc5f0505B35E">0x7Bc5...B35E</a> |
| `token_index`    | Index of sETH token in Curve pool (0 or 1)       | 1                                            | 1                                           |
| `lp_token`       | Address of ETH/sETH Curve pool LP token          | <a href="https://etherscan.io/address/0xA3D87FffcE63B53E0d54fAa1cc983B7eB0b74A9c">0xA3D8...74A9c</a> | <a href="https://optimistic.etherscan.io/address/0x7Bc5728BC2b59B45a58d9A576E2Ffc5f0505B35E">0x7Bc5...B35E</a> |
| `booster`        | Address of the Convex Booster contract           | <a href="https://etherscan.io/address/0xF403C135812408BFbE8713b5A23a04b3D48AAE31">0xF403...AE31</a> | <a href="https://optimistic.etherscan.io/address/0x0000000000000000000000000000000000000000">0x0000...0000</a> |

### Deposit

The deposit is a payable function. The specified payable value is used to borrow the specified `amount` of sETH. No collateral ratio is enforced by the Zap itself (the underlying Synthetix contract will revert if the ratio is too low). 

The contract will return Curve LP token to the users. The `min_lp_tokens_out` parameter can be used to set a minimum expected amount of Curve liquidity tokens to receive in order to prevent front-running.

If the `stake_on_convex` option is set to true on Ethereum mainnet, the Curve LP tokens will automatically be staked on Convex on behalf of the caller.

#### Deposit parameters:

| Param             | Description                                         | Default value |
|-------------------|-----------------------------------------------------|---------------|
| `msg.value`         | Amount of ETH to borrow against                     | N/A           |
| `amount`            | Exact amount of sETH to borrow                      | N/A           |
| `min_lp_tokens_out` | Minimum amount of expected Curve sETH/ETH LP tokens | 0             |
| `stake_on_convex`   | Whether to stake Curve LP tokens on Convex or not   | False         |
