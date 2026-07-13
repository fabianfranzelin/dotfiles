#include "network_utils.h"

#include <cstdint>
#include <cstring>
#include <gtest/gtest.h>
#include <string>
#include <vector>

TEST(BitwiseComparison, EqualArraysReturnTrue)
{
    std::vector<std::uint8_t> a{0, 1, 2, 3, 4};
    std::vector<std::uint8_t> b{0, 1, 2, 3, 4};
    EXPECT_TRUE(bitwise_comparison(a.data(), b.data(), a.size()));
}

TEST(BitwiseComparison, DifferentArraysReturnFalse)
{
    std::vector<std::uint8_t> a{0, 1, 2, 3, 4};
    std::vector<std::uint8_t> b{0, 1, 9, 3, 4};
    EXPECT_FALSE(bitwise_comparison(a.data(), b.data(), a.size()));
}

TEST(BitwiseComparison, EmptyArraysReturnTrue)
{
    std::uint8_t a{};
    std::uint8_t b{};
    EXPECT_TRUE(bitwise_comparison(&a, &b, 0));
}

TEST(ResolveIPv4, EmptyInputReturnsFalse)
{
    std::string resolved;
    EXPECT_FALSE(resolveIPv4("", resolved));
}

TEST(ResolveIPv4, LoopbackResolvesCorrectly)
{
    std::string resolved;
    EXPECT_TRUE(resolveIPv4("127.0.0.1", resolved));
    EXPECT_EQ(resolved, "127.0.0.1");
}

TEST(ResolveIPv4, InvalidHostReturnsFalse)
{
    std::string resolved;
    EXPECT_FALSE(resolveIPv4("this.host.does.not.exist.invalid", resolved));
}
