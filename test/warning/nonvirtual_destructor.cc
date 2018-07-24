
#include <string>

#include <ignition/utilities/SuppressWarning.hh>

class Base
{
  virtual std::string printStuff() = 0;
};

IGN_UTILS_WARN_IGNORE__NON_VIRTUAL_DESTRUCTOR
class Derived : public Base
{
  std::string stuff;
  std::string printStuff() override { return stuff; }
};
IGN_UTILS_WARN_RESUME__NON_VIRTUAL_DESTRUCTOR

Base *MakeDerived()
{
  return new Derived;
}

int main()
{
  Base *b = MakeDerived();
  IGN_UTILS_WARN_IGNORE__NON_VIRTUAL_DESTRUCTOR
  delete b;
  IGN_UTILS_WARN_RESUME__NON_VIRTUAL_DESTRUCTOR
}
