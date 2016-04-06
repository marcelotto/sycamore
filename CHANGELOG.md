# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## [Unreleased]

### Added

- assigning `nil` via `Tree#[]=` removes a child tree, similar to the assignment
  of `Sycamore::Nothing`

### Fixed

- #2: Rubinius support



## [0.2.0] - 2016-04-05

### Added

- assigning `Sycamore::Nothing` via `Tree#[]=` removes a child tree
- `Tree#search` for searching the tree for one or multiple nodes or a tree
- `Tree#node!` as a more strict variant of `Tree#node`, which raises an error 
  when no node present



## 0.1.0 - 2016-03-28

Initial release


[Unreleased]: https://github.com/marcelotto/sycamore/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/marcelotto/sycamore/compare/v0.1.0...v0.2.0
