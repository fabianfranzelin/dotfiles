#include "network_utils.h"

#include <arpa/inet.h>
#include <iostream>
#include <memory>
#include <netdb.h>
#include <sys/socket.h>

bool bitwise_comparison(std::uint8_t* a, std::uint8_t* b, size_t length)
{
    bool ans = true;
    for (size_t i = 0; i < length; i++)
    {
        if (a[i] != b[i])
        {
            std::cout << "(" << i << ") entry differs" << std::endl;
            ans = false;
        }
    }
    return ans;
}

bool resolveIPv4(const std::string& input, std::string& resolvedAddress)
{
    if (input.empty())
    {
        return false;
    }

    struct addrinfo hints = {};
    struct addrinfo* result = nullptr;
    hints.ai_family = AF_INET; // IPv4 only
    hints.ai_socktype = SOCK_STREAM;

    int ret = getaddrinfo(input.c_str(), nullptr, &hints, &result);
    if (ret != 0)
    {
        return false;
    }

    if (!result->ai_addr)
    {
        return false;
    }

    std::unique_ptr<addrinfo, decltype(&freeaddrinfo)> resultGuard(result, freeaddrinfo);
    const auto* sock_addr = reinterpret_cast<const sockaddr_in*>(result->ai_addr);
    char ipstr[INET_ADDRSTRLEN];
    if (inet_ntop(AF_INET, &sock_addr->sin_addr, ipstr, INET_ADDRSTRLEN) == nullptr)
    {
        return false;
    }

    resolvedAddress = ipstr;
    return !resolvedAddress.empty();
}
