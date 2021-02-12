<!-- Please remove the appropriate section.
For example, if this is a new feature, remove the "Bug Fix" section -->

# Bug Fix

Fixes #<NUMBER>

## Summary
<!-- Describe your fix, including an explanation of how to reproduce the bug
before and after the PR.-->

## Checklist
- [ ] Signed all commits for DCO
- [ ] Added tests
- [ ] Updated documentation (as needed)
- [ ] Updated migration guide (as needed)
- [ ] `codecheck` passed (See
  [contributing](https://ignitionrobotics.org/docs/all/contributing#contributing-code))
- [ ] All tests passed (See
  [test coverage](https://ignitionrobotics.org/docs/all/contributing#test-coverage))
- [ ] While waiting for a review on your PR, please help review
[another open pull request](https://github.com/pulls?q=is%3Aopen+is%3Apr+user%3Aignitionrobotics+repo%3Aosrf%2Fsdformat+archived%3Afalse+)
to support the maintainers

**Note to maintainers**: Remember to use **Squash-Merge**

---

# New feature

Closes #<NUMBER>

## Summary
<!--Explain changes made, the expected behavior, and provide any other additional
context (e.g., screenshots, gifs) if appropriate.-->

## Test it
<!--Explain how reviewers can test this new feature manually.-->

## Checklist
- [ ] Signed all commits for DCO
- [ ] Added tests
- [ ] Added example world and/or tutorial
- [ ] Updated documentation (as needed)
- [ ] Updated migration guide (as needed)
- [ ] `codecheck` passed (See [contributing](https://ignitionrobotics.org/docs/all/contributing#contributing-code))
- [ ] All tests passed (See [test coverage](https://ignitionrobotics.org/docs/all/contributing#test-coverage))
- [ ] While waiting for a review on your PR, please help review
[another open pull request](https://github.com/pulls?q=is%3Aopen+is%3Apr+user%3Aignitionrobotics+repo%3Aosrf%2Fsdformat+archived%3Afalse+)
to support the maintainers

**Note to maintainers**: Remember to use **Squash-Merge**

---

# Release

Preparation for <X.Y.Z> release.

Comparison to <x.y.z>: https://github.com/ignitionrobotics/ign-cmake/compare/<LATEST_TAG_BRANCH>...<RELEASE_BRANCH>

## Checklist
- [ ] Asked team if this is a good time for a release
- [ ] There are no changes to be ported from the previous major version
- [ ] No PRs targeted at this major version are close to getting in
- [ ] Bumped minor for new features, patch for bug fixes
- [ ] Updated changelog
- [ ] Updated migration guide (as needed)
- [ ] Open PR updating dependency versions on -release repository (as needed)

<!-- Please refer to http://github.com/docs/release.md#triggering-a-release for more information -->

**Note to maintainers**: Remember to use **Squash-Merge**

---

<!-- For maintainers only -->

# Port

Port <FROM_BRANCH> to <TO_BRANCH>

Branch comparison: https://github.com/ignitionrobotics/ign-cmake/compare/<TO_BRANCH>...<FROM_BRANCH>

**Note to maintainers**: Remember to **Merge** with commit (not squash-merge
or rebase)
