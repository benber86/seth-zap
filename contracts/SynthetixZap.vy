# @version 0.3.4
"""
@title Synthetix sETH to Curve/Convex Zap
@license MIT
"""

interface EthCollateral:
    def open(amount: uint256, currency: bytes32): payable

interface CurvePool:
    def add_liquidity(_amounts: uint256[2], _min_mint_amount: uint256): payable

interface ERC20:
    def balanceOf(_addr: address) -> uint256: view
    def approve(spender: address, amount: uint256): nonpayable
    def transfer(_to: address, amount: uint256): nonpayable
    def transferFrom(_from: address, _to: address, amount: uint256): nonpayable

interface Booster:
    def deposit(_pid: uint256, amount: uint256, _stake: bool) -> bool: nonpayable

interface IRewards:
    def stakeFor(_recipient: address, amount: uint256): nonpayable

# ---- constants ---- #
CURRENCY: constant(bytes32) = 0x7345544800000000000000000000000000000000000000000000000000000000
SETH_CVX_PID: constant(uint256) = 23
CONVEX_DEPOSIT_TOKEN: constant(address) = 0xAF1d4C576bF55f6aE493AEebAcC3a227675e5B98
CONVEX_CRV_REWARDS: constant(address) = 0x192469CadE297D6B21F418cFA8c366b63FFC9f9b

# ---- storage variables ---- #
eth_collateral: public(EthCollateral)
seth: public(address)
seth_curve_pool: public(address)
token_index: uint256
lp_token: address
convex_booster: address


@external
def __init__(
    eth_collateral: address,
    seth: address,
    curve_pool: address,
    token_index: uint256,
    lp_token: address,
    booster: address
):
    """
    @notice Constructor
    @param eth_collateral Address of the Synthetix ETH Collateral contract
    @param seth Address of the sETH token
    @param curve_pool Address of the ETH/sETH Curve pool
    @param token_index Index of sETH token in Curve pool (0 or 1)
    @param lp_token Address of ETH/sETH Curve pool LP token
    @param booster Address of the Convex Booster contract (0 for optimism)
    """
    assert token_index < 2 # dev: wrong token index
    self.eth_collateral = EthCollateral(eth_collateral)
    self.seth = seth
    self.seth_curve_pool = curve_pool
    self.token_index = token_index
    self.lp_token = lp_token
    self.convex_booster = booster


@external
def set_approvals():
    """
    @notice Sets allowances for all needed contracts
    """
    ERC20(self.seth).approve(self.seth_curve_pool, 0)
    ERC20(self.seth).approve(self.seth_curve_pool, MAX_UINT256)
    if self.convex_booster != ZERO_ADDRESS:
        ERC20(self.lp_token).approve(self.convex_booster, 0)
        ERC20(self.lp_token).approve(self.convex_booster, MAX_UINT256)
        ERC20(CONVEX_DEPOSIT_TOKEN).approve(CONVEX_CRV_REWARDS, 0)
        ERC20(CONVEX_DEPOSIT_TOKEN).approve(CONVEX_CRV_REWARDS, MAX_UINT256)


@payable
@external
def deposit(amount: uint256, min_lp_tokens_out: uint256=0, stake_on_convex: bool=False):
    """
    @notice Mints sETH, deposits on Curve and optionally stakes on Convex (mainnet)
    @param amount Exact amount of sETH to borrow
    @param min_lp_tokens_out Minimum amount of expected Curve sETH/ETH LP tokens
    @param stake_on_convex Whether to stake Curve LP tokens on Convex or not
    """
    self.eth_collateral.open(amount, CURRENCY, value=msg.value)
    seth_balance: uint256 = ERC20(self.seth).balanceOf(self)
    amounts: uint256[2] = empty(uint256[2])
    amounts[self.token_index] = seth_balance
    CurvePool(self.seth_curve_pool).add_liquidity(amounts, min_lp_tokens_out)
    lp_token_balance: uint256 = ERC20(self.lp_token).balanceOf(self)
    if stake_on_convex:
        assert self.convex_booster != ZERO_ADDRESS # dev: no convex
        Booster(self.convex_booster).deposit(SETH_CVX_PID, lp_token_balance, False)
        deposit_token_balance: uint256 = ERC20(CONVEX_DEPOSIT_TOKEN).balanceOf(self)
        IRewards(CONVEX_CRV_REWARDS).stakeFor(msg.sender, deposit_token_balance)
    else:
        ERC20(self.lp_token).transfer(msg.sender, lp_token_balance)