import pytest
import brownie
from brownie import Contract


from .abis import CONVEX_STAKE_ABI, ERC20_ABI
from .utils import approx
from .utils.const import CONVEX_CRV_REWARDS, PRECISION
from .utils.estimator import estimate_curve_lp_tokens_received


@pytest.mark.chain("mainnet")
def test_deposit_and_stake_on_convex(zap, alice, constructor_args):
    amount = int(1e18)
    staker = Contract.from_abi(
        name="Convex staker", address=CONVEX_CRV_REWARDS, abi=CONVEX_STAKE_ABI
    )
    initial_balance = staker.balanceOf(alice)
    # estimate amount of curve lp tokens received
    lp_tokens_amount = estimate_curve_lp_tokens_received(
        constructor_args[2], constructor_args[3], amount
    )
    # execute tx
    zap.deposit(amount, 0, True, {"from": alice, "value": amount * 2})
    # convex mint is 1:1
    assert approx(
        staker.balanceOf(alice), initial_balance + lp_tokens_amount, PRECISION
    )


@pytest.mark.chain("op")
def test_deposit_and_stake_on_convex_revert(zap, alice):
    amount = int(1e18)
    with brownie.reverts():
        zap.deposit(amount, 0, True, {"from": alice, "value": amount * 2})


@pytest.mark.chain("mainnet")
@pytest.mark.chain("op")
def test_deposit_only(zap, alice, constructor_args):
    amount = int(1e18)
    lp_token = Contract.from_abi(
        name="Curve LP token", address=constructor_args[4], abi=ERC20_ABI
    )
    initial_balance = lp_token.balanceOf(alice)
    # estimate amount of curve lp tokens received
    lp_tokens_amount = estimate_curve_lp_tokens_received(
        constructor_args[2], constructor_args[3], amount
    )
    # execute tx
    zap.deposit(amount, 0, False, {"from": alice, "value": amount * 2})
    assert approx(
        lp_token.balanceOf(alice), initial_balance + lp_tokens_amount, PRECISION
    )


@pytest.mark.chain("mainnet")
@pytest.mark.chain("op")
def test_slippage(zap, alice):
    amount = int(1e18)
    with brownie.reverts():
        zap.deposit(amount, amount * 10, True, {"from": alice, "value": amount * 2})


@pytest.mark.chain("mainnet")
@pytest.mark.chain("op")
def test_revert_low_collat_ratio(zap, alice):
    amount = int(1e18)
    with brownie.reverts():
        zap.deposit(amount, 0, True, {"from": alice, "value": amount})


@pytest.mark.chain("mainnet")
@pytest.mark.chain("op")
def test_set_approvals(zap, alice, constructor_args):
    seth_token = Contract.from_abi(
        name="sETH", address=constructor_args[1], abi=ERC20_ABI
    )
    zap.set_approvals({"from": alice})
    assert seth_token.allowance(zap, constructor_args[2]) == 2**256 - 1
