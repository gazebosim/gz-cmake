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

#include <gtest/gtest.h>

#include <ignition/utilities/ImplPtr.hh>
#include <pimpl/classes.hh>

using namespace ignition::test::pimpl;

/////////////////////////////////////////////////
TEST(ImplPtr, CopyConstruct)
{
  CopiableObject object(28, "golden_string");
  EXPECT_EQ(28, object.GetInt());
  EXPECT_EQ("golden_string", object.GetString());

  EXPECT_NE(object.GetInt(), CopiableObject().GetInt());
  EXPECT_NE(object.GetString(), CopiableObject().GetString());

  EXPECT_EQ(object.GetInt(), CopiableObject(object).GetInt());
  EXPECT_EQ(object.GetString(), CopiableObject(object).GetString());

  CopiableObject other(object);

  EXPECT_EQ(object.GetInt(), other.GetInt());
  EXPECT_EQ(object.GetString(), other.GetString());
}

/////////////////////////////////////////////////
TEST(ImplPtr, CopyAssign)
{
  CopiableObject object{47, "some_object"};
  EXPECT_EQ(47, object.GetInt());
  EXPECT_EQ("some_object", object.GetString());

  CopiableObject other{};

  EXPECT_NE(object.GetInt(), other.GetInt());
  EXPECT_NE(object.GetString(), other.GetString());

  other = object;
  EXPECT_EQ(object.GetInt(), other.GetInt());
  EXPECT_EQ(object.GetString(), other.GetString());
}

/////////////////////////////////////////////////
TEST(ImplPtr, MoveConstruct)
{
  CopiableObject object(64, "move this thing");
  EXPECT_EQ(64, object.GetInt());
  EXPECT_EQ("move this thing", object.GetString());

  CopiableObject copy(object);
  CopiableObject moved(std::move(object));

  EXPECT_EQ(copy.GetInt(), moved.GetInt());
  EXPECT_EQ(copy.GetString(), moved.GetString());
}

/////////////////////////////////////////////////
TEST(ImplPtr, MoveAssign)
{
  CopiableObject object(78, "we will move assign this");
  EXPECT_EQ(78, object.GetInt());
  EXPECT_EQ("we will move assign this", object.GetString());

  CopiableObject copy(object);

  EXPECT_EQ(object.GetInt(), copy.GetInt());
  EXPECT_EQ(object.GetString(), copy.GetString());

  CopiableObject moved;

  EXPECT_NE(object.GetInt(), moved.GetInt());
  EXPECT_NE(object.GetString(), moved.GetString());

  moved = std::move(object);

  EXPECT_EQ(copy.GetInt(), moved.GetInt());
  EXPECT_EQ(copy.GetString(), moved.GetString());
}

/////////////////////////////////////////////////
TEST(UniqueImplPtr, MoveConstruct)
{
  MoveableObject object(101, "moving this unique thing");
  EXPECT_EQ(101, object.GetInt());
  EXPECT_EQ("moving this unique thing", object.GetString());

  MoveableObject other(101, "moving this unique thing");
  EXPECT_EQ(other.GetInt(), object.GetInt());
  EXPECT_EQ(other.GetString(), object.GetString());

  MoveableObject moved(std::move(object));
  EXPECT_EQ(other.GetInt(), moved.GetInt());
  EXPECT_EQ(other.GetString(), moved.GetString());
}

/////////////////////////////////////////////////
TEST(UniqueImplPtr, MoveAssign)
{
  MoveableObject object(117, "assigning this unique thing");
  EXPECT_EQ(117, object.GetInt());
  EXPECT_EQ("assigning this unique thing", object.GetString());

  MoveableObject other(117, "assigning this unique thing");
  EXPECT_EQ(other.GetInt(), object.GetInt());
  EXPECT_EQ(other.GetString(), object.GetString());

  MoveableObject moved;
  EXPECT_NE(other.GetInt(), moved.GetInt());
  EXPECT_NE(other.GetInt(), moved.GetInt());

  moved = std::move(object);

  EXPECT_EQ(other.GetInt(), moved.GetInt());
  EXPECT_EQ(other.GetString(), moved.GetString());
}

/////////////////////////////////////////////////
int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
