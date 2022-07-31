import brownie.network
import pytest
from brownie import SynthetixZap

from .utils.const import ARGS, OP


def pytest_addoption(parser):
    parser.addoption(
        "--chain",
        action="store",
        metavar="CHAIN",
        default="mainnet",
        help="Specify what chain to run the tests on",
    )


def pytest_configure(config):
    config.addinivalue_line(
        "markers", "chain(CHAIN): only run the tests for specified chain"
    )


def pytest_runtest_setup(item):
    envnames = [mark.args[0] for mark in item.iter_markers(name="chain")]
    if envnames:
        if item.config.getoption("--chain") not in envnames:
            pytest.skip("test requires chain in {!r}".format(envnames))


@pytest.fixture(scope="session")
def chainhandle(pytestconfig):
    return pytestconfig.getoption("chain")


@pytest.fixture(scope="session", autouse=True)
def chain_switch(chainhandle):
    if chainhandle == OP:
        brownie.network.disconnect()
        brownie.network.connect("optimism-fork")


@pytest.fixture(scope="session")
def alice(accounts):
    yield accounts[1]


@pytest.fixture(scope="session")
def bob(accounts):
    yield accounts[2]


@pytest.fixture(scope="session")
def owner(accounts):
    yield accounts[0]


@pytest.fixture(scope="session")
def constructor_args(chainhandle):
    yield ARGS.get(chainhandle)


@pytest.fixture(scope="session")
def zap(owner, constructor_args):
    zap = SynthetixZap.deploy(*constructor_args.values(), {"from": owner})
    zap.set_approvals({"from": owner})
    yield zap
