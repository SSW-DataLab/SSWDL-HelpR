# Contributing to sswdlHelpR

The goal of this guide is to help you understand what is expected of contributions to this package. This helps ensure this package remains maintainable and of high quality.

Contributions can take various forms, but will generally fall into the following categories:

- adding a new feature
- expanding functionality of existing code
- fixing a bug in existing code

What follows is a list of topics to be concerned with when making these contributions.


## Organization

Related functions should be grouped together in the same file. At the time of this writing, each exported function is unrelated to each other one and so has it's own file whose name matches the function name; some of these contain un-exported helper functions as well. If multiple exported functions are grouped in one file, the file should have a more general name.


## Style

All code in this package should be styled similarly; this makes it easier to jump into the code and make changes. This package generally follows prescriptions given in [ClaytonJY's R Styleguide](https://github.com/ClaytonJY/R-Styleguide), but always strive to make your code look similar to other code in this repository.


## Documentation

This package uses `Roxygen2` to auto-generate documentation. Every exported function needs to be well-documented, and this documentation needs to be updated when a function changes.

See [Hadley's guide on using Roxygen2](http://r-pkgs.had.co.nz/man.html), and look at other functions' documentation to see how we use it here.


## Writing Tests

It is expected that every function in this package is well-tested. Tests should be written with `testthat` and strive to cover all errors/warnings as well as behavior. If functionality is changed, tests need to be updated in accordance.

See [Hadley's guide on testing](http://r-pkgs.had.co.nz/tests.html), and look at how other tests in this package are written in `tests/testthat/`.


## Building & Testing

Make sure to build and test before submitting a PR; this will ensure documentation is updated and help minimize regressions.

If using RStudio, see the "Build" tab, and use the "Build & Reload" button. Tests are not automatically run when building a package; you must run tests separately through "Build" > "More" > "Test Package". Do not file a PR unless all tests are passing.

When making a new release, consider running `R CMD check` to ensure the package is in good general health; fixes can go on the appropriate `release/` branch.


## Pull Requests & Git Workflow

This package uses the [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow); it may seem complex, but it helps ensure that versions get bumped appropriately and that installing with `devtools::install_github` never fetches a development version unless explicitly specified.

All changes to this package should be developed on their own feature branch (started from `develop`) and be submitted for approval through a Pull Request on Github. The person who files the PR should generally not be the one approving it. When filing, consider assigning one or more people to the PR to ensure they look at it. If the PR addresses an issue filed on Github, be sure to tag that issue in the PR description.

Pull Requests for new or changed functionality should almost always target the `develop` branch.

This repository is configured to use the squash merging strategy, which will combine all commits from a PR into a single commit which gets added onto the new branch; this helps keep commit history lean and legible. Rebasing will be needed if the target branch has been updated since the feature branch was created. If prompted by Github, be sure to edit the commit message for the squashed commit to be sensible and not simply all the original commit messages appended to one another.


## Versioning

This package follows [Hadley's advice on versioning](http://r-pkgs.had.co.nz/description.html#version): release versions should have the format `major.minor.patch`, and development versions should be `major.minor.patch.dev` where `dev` is at least 9000.


## Releasing

In accordance with the above versioning schema and Gitflow Workflow, making a release should follow these steps:

1. `develop` is sufficently advanced beyond `master` to warrant a new release
2. a `release/<new_version>` branch is created from `develop`
3. on that `release` branch, commits are made to prepare the release; this at least includes changing the version in the `DESCRIPTION` file, and may include other small fixes suggested by `R CMD check`
4. the `release` branch is merged into both `master` and `release`
5. a formal release is created in Github, tied to the new commit on `master`
6. new commit on `develop` appends `.9000` to the version in `DESCRIPTION`


## New Function Checklist

When writing a new function to be included in the package, the following file-level changes are expected at a minimum:

- [ ] new or updated file in `R/` with code for the function
- [ ] new or update file in `tests/testthat/` with tests
- [ ] new file in `man/` with documentation for that file (automatically generated by roxygen)
- [ ] updated `NAMESPACE` file which exports the new function (roxygen)

This can be checked through the "Files changed" tab when creating a Pull Request on Github, e.g. https://github.com/SSW-DataLab/sswdlHelpR/pull/8/files.
