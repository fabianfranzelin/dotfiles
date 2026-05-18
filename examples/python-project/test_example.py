"""Some arbitrary test case."""

import os

import pytest
import numpy


def capital_case(x: str) -> str:
    """Capital case

    :param x: string
    :returns: capital case string

    """

    return x.capitalize()


def test_capital_case() -> None:
    """Some test case"""

    assert capital_case("semaphore") == "Semaphore"


@pytest.mark.xfail(reason="Intentional failure for testing Emacs pytest integration")
def test_failure() -> None:
    assert False
