# comp\_required

A configure-only package used to test how gz-cmake handles optional
components that cannot be built. It has four components:

* `present` has no extra dependencies and is always built.
* `from_src` is always built, and is created in `src/CMakeLists.txt` instead
  of being listed in the `COMPONENTS` of `gz_configure_build`.
* `missing_dep` depends on a package that does not exist, so it is always
  skipped by `gz_find_package`.
* `manual_skip` is always skipped by the project setting
  `INTERNAL_SKIP_manual_skip`.

Only `present` has a directory, since the skipped components are never added.
