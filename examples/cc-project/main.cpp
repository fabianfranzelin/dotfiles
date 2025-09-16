#include <arpa/inet.h> // for inet_ntop
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <memory>
#include <netdb.h> // for getaddrinfo, freeaddrinfo, addrinfo
#include <regex>
#include <string>
#include <sys/socket.h> // for AF_INET
#include <vector>

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

void compare_vectors()
{
    std::vector<size_t> a{0, 1, 2, 3, 4};
    std::vector<size_t> b{0, 1, 2, 3, 4};
    std::vector<size_t> c{0, 1, 2, 3};

    std::cout << "a == b: " << ((a == b) ? "True" : "False") << "\n";
    std::cout << "a == c: " << ((a == c) ? "True" : "False") << "\n";
    std::cout << "b == c: " << ((b == c) ? "True" : "False") << "\n";
}

int main(int, char*[])
{
    size_t length = 10;
    uint8_t* a = (std::uint8_t*)malloc(length * sizeof(std::uint8_t));
    uint8_t* b = (std::uint8_t*)malloc(length * sizeof(std::uint8_t));

    for (size_t i = 0; i < length; i++)
    {
        a[i] = 0;
        b[i] = 0;
    }

    a[5] = 10;

    bitwise_comparison(a, b, length);
    free(a);
    free(b);

    ///////////////////////////////////////////////////////////////////////////
    //                               Check IPv4                              //
    ///////////////////////////////////////////////////////////////////////////
    std::cout << "// IPv4 resolution //////////////////////////////////////////"
              << "\n";

    for (std::string address : {"",
                                "test",
                                "0.0.0.0",
                                "255.255.255.255",
                                "127.0.0.1",
                                "255.255.256.255",
                                "localhost",
                                "local_host",
                                "162.172.0.3"})
    {
        std::string resolvedAddress;
        bool ret = resolveIPv4(address, resolvedAddress);
        std::cout << "[" << (ret ? "Success" : "Failure") << "] " << (address.empty() ? "None" : address) << " -> "
                  << (resolvedAddress.empty() ? "None" : resolvedAddress) << "\n";
    }


    ///////////////////////////////////////////////////////////////////////////
    //                              port limits                              //
    ///////////////////////////////////////////////////////////////////////////
    std::cout << "// Port limits //////////////////////////////////////////////"
              << "\n";
    std::cout << "lower limit: 0"
              << "\n";
    std::cout << "upper limit: " << std::numeric_limits<uint16_t>::max() << "\n";


    ///////////////////////////////////////////////////////////////////////////
    //                            Compare vectors                            //
    ///////////////////////////////////////////////////////////////////////////
    compare_vectors();

    return 0;
}
