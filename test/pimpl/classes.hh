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

#ifndef IGNITION_CMAKE_TEST_PIMPL_CLASSES_HH_
#define IGNITION_CMAKE_TEST_PIMPL_CLASSES_HH_

#include <ignition/utilities/ImplPtr.hh>

namespace ignition
{
  namespace test
  {
    namespace pimpl
    {
      /// \brief A PIMPL test class that can be copied.
      class CopiableObject
      {
        /// \brief Constructor
        public: CopiableObject(int _ivalue = 0,
                               const std::string &_svalue = "");

        /// \brief Get the int value held by the pimpl
        public: int GetInt() const;

        /// \brief Set the int value held by the pimpl
        public: void SetInt(const int _value);

        /// \brief Get the string value held by the pimpl
        public: const std::string &GetString() const;

        /// \brief Set the string value held by the pimpl
        public: void SetString(const std::string &_value);

        // Forward declare
        private: class Implementation;

        /// \brief Pointer to implementation
        private: utilities::ImplPtr<Implementation> dataPtr;
      };

      /// \brief A PIMPL test class that cannot be copied; it can only be moved.
      class MoveableObject
      {
        /// \brief Constructor
        public: MoveableObject(int _ivalue, const std::string &_svalue = "");

        /// \brief Get the int value held by the pimpl
        public: int GetInt() const;

        /// \brief Set the int value held by the pimpl
        public: void SetInt(const int _value);

        /// \brief Get the string value held by the pimpl
        public: const std::string &GetString() const;

        /// \brief Set the string value held by the pimpl
        public: void SetString(const std::string &_value);

        // Forward declare
        private: class Implementation;

        /// \brief Pointer to implementation
        private: utilities::UniqueImplPtr<Implementation> dataPtr;
      };
    }
  }
}

#endif
