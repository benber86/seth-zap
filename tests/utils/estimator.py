from brownie import Contract

from tests.abis import CURVE_ABI


def estimate_curve_lp_tokens_received(curve_pool, curve_index, amount):
    pool_contract = Contract.from_abi(name="sETH", address=curve_pool, abi=CURVE_ABI)
    amounts = [0] * 2
    amounts[curve_index] = amount
    return pool_contract.calc_token_amount(amounts, True)
