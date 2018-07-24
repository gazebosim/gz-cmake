
#include <string>

#include <ignition/utilities/SuppressWarning.hh>

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
  IGN_UTILS_WARN_IGNORE__DELETE_NON_VIRTUAL_DESTRUCTOR
  delete b;
  IGN_UTILS_WARN_RESUME__DELETE_NON_VIRTUAL_DESTRUCTOR
}
