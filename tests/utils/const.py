ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"
CONVEX_CRV_REWARDS = "0x192469CadE297D6B21F418cFA8c366b63FFC9f9b"
PRECISION = 0.005
MAINNET = "mainnet"
OP = "op"

MAINNET_ARGS = {
    "_eth_collateral": "0x5c8344bcdC38F1aB5EB5C1d4a35DdEeA522B5DfA",
    "_seth": "0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb",
    "_curve_pool": "0xc5424B857f758E906013F3555Dad202e4bdB4567",
    "_token_index": 1,
    "_lp_token": "0xA3D87FffcE63B53E0d54fAa1cc983B7eB0b74A9c",
    "_booster": "0xF403C135812408BFbE8713b5A23a04b3D48AAE31",
}

OPTIMISM_ARGS = {
    "_eth_collateral": "0x308AD16ef90fe7caCb85B784A603CB6E71b1A41a",
    "_seth": "0xE405de8F52ba7559f9df3C368500B6E6ae6Cee49",
    "_curve_pool": "0x7Bc5728BC2b59B45a58d9A576E2Ffc5f0505B35E",
    "_token_index": 1,
    "_lp_token": "0x7Bc5728BC2b59B45a58d9A576E2Ffc5f0505B35E",
    "_booster": ZERO_ADDRESS,
}

ARGS = {MAINNET: MAINNET_ARGS, OP: OPTIMISM_ARGS}
