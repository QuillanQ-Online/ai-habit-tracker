# Repository Development Guidelines

All work within this repository must follow the directives below. These
instructions apply to the entire project unless superseded by a more specific
`AGENTS.md` placed in a subdirectory.

## Process Expectations
- Practice **test-driven development (TDD)** for every change:
  1. Plan the change and capture the proposed steps.
  2. Create stubs/skeletons for new code paths.
  3. Write failing unit tests that describe the desired behaviour.
  4. Implement the functionality to satisfy the tests.
- Break work into small, consistent commits. Document the plan and progress
  using checklists that align with the TDD workflow above.
- Run the complete automated test suite after every code change. Tests must
  pass before a pull request can be submitted.
- Maintain at least **80% unit-test coverage** as reported by XCTest.
- Ensure every change is recorded in the repository's documentation catalog and
  appended to the root-level changelog.

## Architectural Requirements
- Design all code according to:
  - [SOLID principles](https://www.geeksforgeeks.org/system-design/solid-principle-in-programming-understand-with-real-life-examples/).
  - [Clean Architecture](https://www.geeksforgeeks.org/system-design/complete-guide-to-clean-architecture/).
- Adhere to the [Dart style guidelines](https://dart.dev/effective-dart/style).

## Quality Gates for Pull Requests
- Unit tests must pass and demonstrate the required coverage threshold prior to
  merging.
- Each pull request must explicitly note how test coverage and test results
  were validated.
- Ensure the documentation catalog and changelog entries reflect every change
  included in the pull request.

