#include "network_utils.h"

#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <string>
#include <vector>

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
    std::cout << "// IPv4 resolution //////////////////////////////////////////" << "\n";

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
    std::cout << "// Port limits //////////////////////////////////////////////" << "\n";
    std::cout << "lower limit: 0" << "\n";
    std::cout << "upper limit: " << std::numeric_limits<uint16_t>::max() << "\n";


    ///////////////////////////////////////////////////////////////////////////
    //                            Compare vectors                            //
    ///////////////////////////////////////////////////////////////////////////
    compare_vectors();

    return 0;
}
