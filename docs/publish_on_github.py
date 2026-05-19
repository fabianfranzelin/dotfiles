"""Push documentation to Github pages."""

__copyright__ = """
"""

import datetime
import os
import shutil
import tempfile
from pathlib import Path
import sys
import logging
from typing import Optional
from argparse import ArgumentParser, Namespace

from git import Repo
from git.exc import GitCommandError


def get_logger(
    logging_level: int = logging.INFO,
    base_path: Optional[Path] = None,
) -> logging.Logger:
    """Create a logger.

    :param logging_level: logging level of the logger
    :param base_path:
    :returns: logger
    """
    log_format = "%(levelname).1s%(asctime)s.%(msecs).03d %(process)d %(filename)s:%(lineno)d] %(message)s"
    date_format = "%m%d %H:%M:%S"

    # Get the root logger
    logger = logging.getLogger("py_sphinx_docs")
    logger.setLevel(logging_level)

    # Create console handler and set level to debug
    if not logger.handlers:
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging_level)

        # Create formatter
        formatter = logging.Formatter(fmt=log_format, datefmt=date_format)

        # Add formatter to console_handler
        console_handler.setFormatter(formatter)

        # Add console_handler
        logger.addHandler(console_handler)

    # Add file handler if base path is specified
    if base_path:
        logfile_folder = base_path / "logs"
        logfile_folder.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(
            logfile_folder / "sphinx_docs.log", mode="w", encoding="utf8"
        )
        logger.addHandler(file_handler)

    return logger


# Options for the conversion.
PROJECT_ROOT = Path(__file__).parent
LOGGER = get_logger()


def check_dependencies() -> bool:
    """Check whether the third party dependencies are available.

    :returns: whether all required third party dependencies are installed or not.

    """
    is_valid = True
    if not shutil.which("git"):
        LOGGER.error("git not found. Something is really wrong with your setup.")
        is_valid = False

    return is_valid


def run_publish_on_github(
    built_docs_dir: Path, remote: str = "origin", dryrun: bool = False
) -> int:
    """Publish specified document on Github pages.

    :param built_docs_dir: path to built documentation
    :param remote: remote where the changes should be published to
    :param dryrun: whether github should actually be updated or not

    :returns: whether publication was successful or not
    """
    if not check_dependencies():
        return 1

    tmp_dir = Path(tempfile.mkdtemp())
    github_pages_branchname = "gh-pages"
    LOGGER.info("Publishing documentation using tmp folder %s", tmp_dir)

    # get root of git repository
    target_git_repo = Repo(built_docs_dir, search_parent_directories=True)
    project_root = Path(target_git_repo.git.rev_parse("--show-toplevel"))
    assert project_root.is_dir()
    shutil.copytree(project_root / ".git", tmp_dir / ".git")

    LOGGER.info("Clean up the temporary repository %s", github_pages_branchname)
    git_repo = Repo(tmp_dir).git
    LOGGER.info("Git reset, checkout and clean")
    git_repo.reset()
    LOGGER.info("Git checkout")
    git_repo.checkout("--", ".")
    LOGGER.info("Git clean")
    git_repo.clean("-dfx")
    LOGGER.info("Git pull")
    git_repo.pull()
    LOGGER.info("Checkout github pages branch")
    git_repo.checkout(github_pages_branchname)
    print("Pull github pages branch")
    git_repo.pull(remote, github_pages_branchname)

    # Remove everything in the repo
    LOGGER.info("Copy sphinx builds the temporary folder %s", tmp_dir)
    if not built_docs_dir.is_dir():
        LOGGER.error(
            "Document source does not exist. Build the html document before you continue."
        )
        return 2

    LOGGER.info("Remove all files that are not in .git")
    for filename in os.listdir(tmp_dir):
        if filename not in [".git"]:
            file_path = tmp_dir / filename
            if not file_path.is_dir():
                os.remove(file_path)
            else:
                shutil.rmtree(str(tmp_dir / filename))

    shutil.copytree(built_docs_dir, tmp_dir, dirs_exist_ok=True)

    if not (tmp_dir / "index.html").is_file():
        LOGGER.error("Html ressource not found. Run build has failed.")
        return 3

    LOGGER.info(
        "Add .nojekyll to root folder. This is required for css rendering on pages."
    )
    (tmp_dir / ".nojekyll").touch()
    try:
        LOGGER.info("Commit all the changes.")
        git_repo.add(".")
        git_repo.commit(
            "--no-verify", "-m", f"new pages version {datetime.datetime.now()}"
        )
        if not dryrun:
            LOGGER.info("Push to remote.")
            git_repo.push(remote, github_pages_branchname)
        else:
            LOGGER.info("Skip push to remote.")
    except GitCommandError:
        LOGGER.info("No changes to be commited. Pages are already up to date.")

    return 0


def parse_arguments() -> Namespace:
    """Create argument parser for package."""
    parser = ArgumentParser(description="")
    subparser = parser.add_subparsers(dest="command")

    # -----------------------------------------------------------
    # Publisher
    publish_builder = subparser.add_parser("publish")
    publish_builder.add_argument(
        "--dryrun",
        action="store_true",
        help="Do not actually publish anything, just try.",
    )

    return parser.parse_args()


if __name__ == "__main__":
    # parse command line arguments
    args = parse_arguments()
    exit_code: int = run_publish_on_github(
        Path("./public").resolve(),
        remote="origin",
        dryrun=args.dryrun,
    )
    sys.exit(exit_code)
