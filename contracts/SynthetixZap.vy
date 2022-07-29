# @version 0.3.3
"""
@title Synthetix sETH to Curve/Convex Zap
@license MIT
"""

interface EthCollateral:
    def open(amount: uint256, currency: bytes32) -> uint256: payable

interface CurvePool:
    def add_liquidity(_amounts: uint256[2], _min_mint_amount: uint256): payable

interface ERC20:
    def balanceOf(_addr: address) -> uint256: view
    def approve(spender: address, amount: uint256): nonpayable
    def transfer(_to: address, _amount: uint256): nonpayable
    def transferFrom(_from: address, _to: address, _amount: uint256): nonpayable

interface Booster:
    def deposit(_pid: uint256, _amount: uint256, _stake: bool) -> bool: nonpayable

interface IRewards:
    def stakeFor(_recipient: address, _amount: uint256): nonpayable

# ---- constants ---- #
CURRENCY: constant(bytes32) = 0x7355534400000000000000000000000000000000000000000000000000000000
SETH_CVX_PID: constant(uint256) = 23
CONVEX_DEPOSIT_TOKEN: constant(address) = 0xAF1d4C576bF55f6aE493AEebAcC3a227675e5B98
CONVEX_CRV_REWARDS: constant(address) = 0x192469CadE297D6B21F418cFA8c366b63FFC9f9b

# ---- storage variables ---- #
eth_collateral: public(EthCollateral)
seth: public(address)
seth_curve_pool: address
token_index: uint256
lp_token: address
convex_booster: address


@external
def __init__(
    _eth_collateral: address,
    _seth: address,
    _curve_pool: address,
    _token_index: uint256,
    _lp_token: address,
    _booster: address
):
    """
    @param _eth_collateral: address of the Synthetix ETH Collateral contract
    @param _seth: address of the seth ERC20 token
    @param _curve_pool: address of the sETH/ETH Curve pool
    @param _token_index: index of the seth token in the Curve pool (0 or 1)
    @param _lp_token: address of the sETH/ETH Curve pool LP token
    @param _booster: address of Convex's booster contract (use address 0 on OP)
    """
    assert _token_index < 2 # dev: wrong token index
    self.eth_collateral = EthCollateral(_eth_collateral)
    self.seth = _seth
    self.seth_curve_pool = _curve_pool
    self.token_index = _token_index
    self.lp_token = _lp_token
    self.convex_booster = _booster


@external
def set_approvals():
    ERC20(self.seth).approve(self.seth_curve_pool, 0)
    ERC20(self.seth).approve(self.seth_curve_pool, MAX_UINT256)
    if self.convex_booster != ZERO_ADDRESS:
        ERC20(self.lp_token).approve(self.convex_booster, 0)
        ERC20(self.lp_token).approve(self.convex_booster, MAX_UINT256)
        ERC20(CONVEX_DEPOSIT_TOKEN).approve(CONVEX_CRV_REWARDS, 0)
        ERC20(CONVEX_DEPOSIT_TOKEN).approve(CONVEX_CRV_REWARDS, MAX_UINT256)


@payable
@external
def deposit(_amount: uint256, _min_lp_tokens_out: uint256=0, _stake_on_convex: bool=False):
    self.eth_collateral.open(_amount, CURRENCY, value=msg.value)
    seth_balance: uint256 = ERC20(self.seth).balanceOf(self)
    amounts: uint256[2] = empty(uint256[2])
    amounts[self.token_index] = seth_balance
    CurvePool(self.seth_curve_pool).add_liquidity(amounts, _min_lp_tokens_out)
    if _stake_on_convex:
        assert self.convex_booster != ZERO_ADDRESS # dev: no convex
        lp_token_balance: uint256 = ERC20(self.lp_token).balanceOf(self)
        Booster(self.convex_booster).deposit(SETH_CVX_PID, lp_token_balance, False)
        deposit_token_balance: uint256 = ERC20(CONVEX_DEPOSIT_TOKEN).balanceOf(self)
        IRewards(CONVEX_CRV_REWARDS).stakeFor(msg.sender, deposit_token_balance)


    

