"""Main Python module."""

import pathlib
import numpy as np


def f(a: int, b: int) -> int:
    """Some function.

    :param a: firs value
    :param b: second value
    :returns: sum of both parameters
    """
    return a + b


def main() -> None:
    """Main."""
    a = 10
    b = 20
    c = f(a, b)
    print(c)

    path = pathlib.Path("/tmp")
    print(path)

    a = np.array([10, 20])
    print(np.dot(a, a.T))


if __name__ == "__main__":
    main()
