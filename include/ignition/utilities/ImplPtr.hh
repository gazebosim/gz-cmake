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

#ifndef IGNITION_UTILITIES_IMPLPTR_HH_
#define IGNITION_UTILITIES_IMPLPTR_HH_

#include <memory>

#include <ignition/utilities/detail/DefaultOps.hh>

namespace ignition
{
  namespace utilities
  {
    namespace detail
    {
      //////////////////////////////////////////////////
      template <class T,
                class CopyConstruct = T* (*)(const T&),
                class CopyAssign = void (*)(T&, const T&)>
      struct CopyMoveDeleteOperations
      {
        public: template <class C, class A>
        CopyMoveDeleteOperations(C &&_construct, A &&_assign);

        public: CopyConstruct construct;
        public: CopyAssign assign;
      };
    }

    //////////////////////////////////////////////////
    template <class T,
              class Deleter = void (*)(T*),
              class Operations = detail::CopyMoveDeleteOperations<T> >
    class ImplPtr
    {
      public: template <class U, class D, class Ops>
      ImplPtr(U *_ptr, D &&_deleter, Ops &&_ops);

      public: ImplPtr(const ImplPtr &_other);

      public: ImplPtr &operator=(const ImplPtr &_other);

      public: ImplPtr(ImplPtr &&_other) = default;

      public: ImplPtr &operator=(ImplPtr &&_other) = default;

      public: ImplPtr clone() const;

      public: ~ImplPtr() = default;

      public: T &operator*();

      public: const T &operator*() const;

      public: T *operator->();

      public: const T *operator->() const;

      private: std::unique_ptr<T, Deleter> ptr;

      private: Operations ops;
    };

    //////////////////////////////////////////////////
    template <class T, typename... Args>
    ImplPtr<T> MakeImpl(Args &&...args)
    {
      return ImplPtr<T>(
            new T{std::forward<Args>(args)...},
            &detail::DefaultDelete<T>,
            detail::CopyMoveDeleteOperations<T>(
              &detail::DefaultCopyConstruct<T>,
              &detail::DefaultCopyAssign<T>));
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter = void (*)(T*)>
    using UniqueImplPtr = std::unique_ptr<T, Deleter>;

    //////////////////////////////////////////////////
    template <class T, typename... Args>
    inline UniqueImplPtr<T> MakeUniqueImpl(Args &&...args)
    {
      return UniqueImplPtr<T>(
            new T{std::forward<Args>(args)...},
            &detail::DefaultDelete<T>);
    }

  }
}

#include <ignition/utilities/detail/ImplPtr.hh>

#endif
