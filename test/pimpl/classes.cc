/*
 * Copyright (C) 2018 Open Source Robotics Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
*/

#include "classes.hh"

using namespace ignition;
using namespace ignition::test::pimpl;

//////////////////////////////////////////////////
class CopiableObject::Implementation
{
  public: int ivalue;
  public: std::string svalue;
};

//////////////////////////////////////////////////
CopiableObject::CopiableObject(const int _ivalue,
                               const std::string &_svalue)
  : dataPtr(utilities::MakeImpl<Implementation>(_ivalue, _svalue))
{
  // Do nothing
}

//////////////////////////////////////////////////
int CopiableObject::GetInt() const
{
  return dataPtr->ivalue;
}

//////////////////////////////////////////////////
void CopiableObject::SetInt(const int _value)
{
  dataPtr->ivalue = _value;
}

//////////////////////////////////////////////////
const std::string &CopiableObject::GetString() const
{
  return (*dataPtr).svalue;
}

//////////////////////////////////////////////////
void CopiableObject::SetString(const std::string &_value)
{
  (*dataPtr).svalue = _value;
}

//////////////////////////////////////////////////
class MoveableObject::Implementation
{
  public: int ivalue;
  public: std::string svalue;
};

//////////////////////////////////////////////////
MoveableObject::MoveableObject(const int _ivalue, const std::string &_svalue)
  : dataPtr(utilities::MakeUniqueImpl<Implementation>(_ivalue, _svalue))
{
  // Do nothing
}

//////////////////////////////////////////////////
int MoveableObject::GetInt() const
{
  return dataPtr->ivalue;
}

//////////////////////////////////////////////////
void MoveableObject::SetInt(const int _value)
{
  dataPtr->ivalue = _value;
}

//////////////////////////////////////////////////
const std::string &MoveableObject::GetString() const
{
  return (*dataPtr).svalue;
}

//////////////////////////////////////////////////
void MoveableObject::SetString(const std::string &_value)
{
  (*dataPtr).svalue = _value;
}
