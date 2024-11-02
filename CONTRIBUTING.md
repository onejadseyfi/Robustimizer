# Contributing to Robustimizer

## Introduction

Welcome to the Robustimizer project! We appreciate your interest in contributing to our Matlab-based application for surrogate-model-based robust optimization. Whether you're fixing a bug, adding a new feature, or improving documentation, your contributions are valuable to us.

## How to Report Issues

If you encounter any issues or have suggestions for improvements, please [submit them](https://gitlab.tudelft.nl/onejadseyfi/robustimizer-internal/-/issues) via the project's GitLab pages. Make sure to provide as much detail as possible to help us understand and resolve the issue.

## How to Submit Changes

We accept contributions both as patches and pull requests (using forks). To submit changes:

1. Fork the repository on GitLab.
2. Create a new branch for your changes.
3. Make your changes and commit them with clear and descriptive messages.
4. Push your changes to your fork.
5. Submit a merge request to the main repository.

Remember, by contributing, you agree that your contributions will be made under the project's open-source license.

## Development Setup

To set up the development environment:

1. Clone the repository to your local machine.
2. Start Matlab and change to the `src` directory.
3. Run the `filepaths.m` script to set up the required paths:

    ```matlab
    filepaths
    ```

4. You can now run the `Robustimizer2024.mlapp` app to start the application:

    ```matlab
    Robustimizer2024
    ```

## Testing Guidelines

We use Matlab's `matlab.unittest` framework for testing. To run the tests:

1. Ensure your development environment is set up.
2. Navigate to the `test` directory.
3. Run the test suite:

    ```matlab
    runtests
    ```

Please add tests for any new features or bug fixes you implement.

## Coding Standards

- Follow Matlab's coding conventions.
- Use descriptive variable and function names.
- Include comments and documentation for your code.
- Ensure your code is well-formatted and readable.

## Branching Model

We use the following branching model:

- `master`: The branch where new features and bug fixes are integrated. This will eventually become the next release.
- Feature branches: For new features (`feature/your-feature-name`).
- Bugfix branches: For bug fixes (`bugfix/your-bugfix-name`).
- Release branches: For preparing releases (`release/x.y.z`).
- Tagging: For marking releases (`vX.Y.Z`).

## Review Process

All contributions will go through a review process:

1. Submit a merge request.
2. The maintainers will review your changes and provide feedback.
3. Address any feedback and update your merge request.
4. Once approved, your changes will be merged into the project.

## License Information

This project is licensed under the terms specified in the [LICENSE.md](LICENSE.md) file. By contributing, you agree that your contributions will be made under this license.

## Contact Information

For any questions or further assistance, please contact the project maintainers via the project's GitLab pages.

## Additional Resources

- [Technical details (Word) document](documentation/Technical details.docx)
- [Application Design](documentation/Application Design.md)
- [README.md](README.md)

Thank you for contributing to Robustimizer!
