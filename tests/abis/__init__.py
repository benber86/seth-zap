import json
from pathlib import Path


with Path(__file__).with_name("Curve.json").open("r") as fp:
    CURVE_ABI = json.load(fp)


with Path(__file__).with_name("ERC20.json").open("r") as fp:
    ERC20_ABI = json.load(fp)


with Path(__file__).with_name("BaseRewardPool.json").open("r") as fp:
    CONVEX_STAKE_ABI = json.load(fp)
