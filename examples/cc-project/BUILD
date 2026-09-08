load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library", "cc_test")

cc_library(
    name = "network_utils",
    srcs = ["src/network_utils.cpp"],
    hdrs = ["include/network_utils.h"],
    includes = ["include"],
)

cc_binary(
    name = "main",
    srcs = ["main.cpp"],
    deps = [":network_utils"],
)

cc_test(
    name = "network_utils_test",
    srcs = ["test/network_utils_test.cpp"],
    deps = [
        ":network_utils",
        "@googletest//:gtest_main",
    ],
)

refresh_compile_commands(
    name = "refresh_compile_commands",
    targets = [
        "//:main",
        "//:network_utils_test",
    ],
)
