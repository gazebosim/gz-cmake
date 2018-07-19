
#include <string>

class Base
{
  virtual std::string printStuff() = 0;
};

class Derived : public Base
{
  std::string stuff;
  std::string printStuff() override { return stuff; }
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
