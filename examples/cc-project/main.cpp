#include <cstdint>
#include <cstdlib>
#include <iostream>

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

int main(int argc, char* argv[])
{
    size_t length = 10;
    std::uint8_t* a = (std::uint8_t*)malloc(length * sizeof(std::uint8_t));
    std::uint8_t* b = (std::uint8_t*)malloc(length * sizeof(std::uint8_t));

    for (size_t i = 0; i < length; i++)
    {
        a[i] = 0;
        b[i] = 0;
    }

    a[5] = 10;

    bitwise_comparison(a, b, length);
    free(a);
    free(b);
    return 0;
}
