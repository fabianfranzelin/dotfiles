"""Some arbitrary test case."""


import os

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


def test_failure() -> None:
    assert False
