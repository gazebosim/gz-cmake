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

#ifndef IGNITION_UTILITIES_DETAIL_IMPLPTR_HH_
#define IGNITION_UTILITIES_DETAIL_IMPLPTR_HH_

#include <ignition/utilities/ImplPtr.hh>

namespace ignition
{
  namespace utilities
  {
    namespace detail
    {
      //////////////////////////////////////////////////
      template <class T, class CopyConstruct, class CopyAssign>
      template <class C, class A>
      CopyMoveDeleteOperations<T, CopyConstruct, CopyAssign>::
      CopyMoveDeleteOperations(C &&_construct, A &&_assign)
        : construct(_construct),
          assign(_assign)
      {
        // Do nothing
      }
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    template <typename Ptr, class D, class Ops>
    ImplPtr<T, Deleter, Operations>::ImplPtr(
        Ptr *_ptr, D &&_deleter, Ops &&_ops)
      : ptr(_ptr, std::forward<D>(_deleter)),
        ops(std::forward<Ops>(_ops))
    {
      // Do nothing
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    ImplPtr<T, Deleter, Operations>::ImplPtr(const ImplPtr &_other)
      // Delegate to the move constructor after cloning
      : ImplPtr(_other.clone())
    {
      // Do nothing
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    auto ImplPtr<T, Deleter, Operations>::operator=(
        const ImplPtr &_other) -> ImplPtr&
    {
      if (this->ptr)
        this->ops.assign(*this->ptr, *_other.ptr);
      else
        this->ptr.reset(this->ops.construct(*_other.ptr));

      return *this;
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    auto ImplPtr<T, Deleter, Operations>::clone() const -> ImplPtr
    {
      return ImplPtr(this->ptr ? this->ops.construct(*this->ptr) : nullptr,
                     this->ptr.get_deleter(),
                     this->ops);
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    T &ImplPtr<T, Deleter, Operations>::operator*()
    {
      return *ptr;
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    const T &ImplPtr<T, Deleter, Operations>::operator*() const
    {
      return *ptr;
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    T *ImplPtr<T, Deleter, Operations>::operator->()
    {
      return ptr.get();
    }

    //////////////////////////////////////////////////
    template <class T, class Deleter, class Operations>
    const T *ImplPtr<T, Deleter, Operations>::operator->() const
    {
      return ptr.get();
    }
  }
}

#endif
