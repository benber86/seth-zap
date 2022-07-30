from brownie import accounts, SynthetixZap
import brownie

from tests.utils.const import ARGS


def main():
    constructor_args = ARGS.get(
        "op" if brownie.network.show_active().startswith("optimism") else "mainnet"
    )
    deployer = accounts.load("mainnet-deploy")
    zap = SynthetixZap.deploy(
        *constructor_args, {"from": deployer}, publish_source=True
    )
    zap.set_approvals({"from": deployer})
