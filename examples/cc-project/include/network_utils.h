#pragma once

#include <cstdint>
#include <cstddef>
#include <string>

bool bitwise_comparison(std::uint8_t* a, std::uint8_t* b, size_t length);

bool resolveIPv4(const std::string& input, std::string& resolvedAddress);
