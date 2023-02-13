#include <iostream>

int f(int a)
{
    return a * 10;
}

int main(int argc, char* argv[])
{
  std::cout << "Hello world" << std::endl;
  int a = 10;
  std::cout << "f(" << a << ") = " << f(a) << std::endl;
  return 0;
}
