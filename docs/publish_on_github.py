#! /usr/bin/env python3

"""Push documentation to Github pages."""

import datetime
import os
import shutil
import sys
import tempfile
from argparse import ArgumentParser, Namespace
from pathlib import Path

from git import Repo
from git.exc import GitCommandError


def run_publish_on_github(built_docs_dir: Path, dryrun: bool = False) -> int:
    """Publish specified document on Github pages.

    :param built_docs_dir: path to built documentation
    :param dryrun: whether github should actually be updated or not

    :returns: whether publication was successful or not
    """
    tmp_dir = Path(tempfile.mkdtemp())
    github_pages_branchname = "gh-pages"
    print(f"Publishing documentation using tmp folder {tmp_dir}")

    # get root of git repository
    target_git_repo = Repo(built_docs_dir, search_parent_directories=True)
    project_root = Path(target_git_repo.git.rev_parse("--show-toplevel"))
    assert project_root.is_dir()
    shutil.copytree(project_root / ".git", tmp_dir / ".git")

    print(f"Clean up the temporary repository {github_pages_branchname}")
    git_repo = Repo(tmp_dir).git
    git_repo.reset()
    git_repo.checkout("--", ".")
    git_repo.clean("-dfx")
    git_repo.pull()
    git_repo.checkout(github_pages_branchname)
    git_repo.pull("origin", github_pages_branchname)

    # Remove everything in the repo
    print(f"Copy sphinx builds the temporary folder {tmp_dir}")
    if not built_docs_dir.is_dir():
        print(
            "Document source does not exist. "
            "Build the html document before you continue."
        )
        return 2

    print("Remove all files that are not in .git")
    for filename in os.listdir(tmp_dir):
        if filename not in [".git"]:
            file_path = tmp_dir / filename
            if file_path.is_file() or file_path.is_symlink():
                os.remove(file_path)
            else:
                shutil.rmtree(str(file_path))

    shutil.copytree(built_docs_dir, tmp_dir, dirs_exist_ok=True)

    if not (tmp_dir / "index.html").is_file():
        print("Html ressource not found. Run build has failed.")
        return 3

    print("Add .nojekyll to root folder. This is required for css rendering on pages.")
    (tmp_dir / ".nojekyll").touch()

    print("Add README.org to root folder.")
    with open(tmp_dir / "README.org", encoding="utf-8", mode="w") as fd:
        fd.write(
            """
#+TITLE: dotfiles (docs)
#+AUTHOR: Fabian Franzelin
#+EMAIL: fabian.franzelin@gmail.com
#+CREATOR: Fabian Franzelin
#+LANGUAGE: en

The documentation is published [[https://fabianfranzelin.github.io/dotfiles][here]].
        """
        )

    try:
        print("Commit all the changes.")
        git_repo.add(".")
        git_repo.commit(
            "--no-verify", "-m", f"new pages version {datetime.datetime.now()}"
        )
        if not dryrun:
            print("Push to remote.")
            git_repo.push("origin", github_pages_branchname)
        else:
            print("Skip push to remote.")
    except GitCommandError:
        print("No changes to be commited. Pages are already up to date.")

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
        dryrun=args.dryrun,
    )
    sys.exit(exit_code)
