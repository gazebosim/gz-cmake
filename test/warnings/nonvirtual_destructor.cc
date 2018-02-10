
#include <string>

class Base
{
  std::string stuff;
};

class Derived : public Base
{
  std::string moreStuff;
};

Base *MakeDerived()
{
  return new Derived;
}

int main()
{
  Base *b = MakeDerived();
  delete b;
}
