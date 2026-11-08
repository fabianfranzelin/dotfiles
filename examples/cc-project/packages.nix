{ pkgs }:

with pkgs;
[
  # build
  (import ./bazel.nix { inherit pkgs; })
  cmake
  ninja
  gnumake
  python3
  gdb
  openssl # builds the Java trust store in .envrc

  # editor tooling
  clang-tools # clangd, clang-format
  cmake-language-server
  starpls
  bazel-buildtools # buildifier

  # git & pass
  git
  git-lfs
  openssh
  less
  pass
  gnupg

  # basic utilities expected by Emacs, shells and scripts
  bashInteractive
  coreutils
  findutils
  diffutils
  gnugrep
  gnused
  gawk
  gnutar
  gzip
  unzip
  which
  ripgrep
  fd
]
