# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).

## Unreleased

### Added

- array-access operator and `fetch` on `Path` for random access

[Compare v0.3.0...Unreleased](https://github.com/marcelotto/sycamore/compare/v0.3.0...HEAD)


## 0.3.0 - 2016-04-23

### Added

- support `Path` objects as input on the following `Tree` methods:
  - the `Tree.[]` population constructor
  - `fetch`
  - `add` 
  - `delete`
  - `replace`
  - `[]=`
  - `include_node?`
  - `leaf?`
  - `strict_leaf?`
  - `strict_leaves?`
  - `internal?`
  - `external?`
- `Tree#fetch_path` for fetching a child by path 

### Fixed

- `Tree#add` or `Tree#delete` now fail without making any changes, when given 
  invalid input. Previously these command methods performed their operations  
  until the invalid input elements were encountered.
- `Tree#delete` deleted paths, when they matched a given input path partially,
  e.g. `Tree[a: 1] >> a: {1 => 2}` deleted successfully.

[Compare v0.2.1...v0.3.0](https://github.com/marcelotto/sycamore/compare/v0.2.1...v0.3.0)



## 0.2.1 - 2016-04-07

### Added

- assigning `nil` via `Tree#[]=` removes a child tree, similar to the assignment
  of `Sycamore::Nothing`

### Fixed

- [#2](https://github.com/marcelotto/sycamore/issues/2): Rubinius support

[Compare v0.2.0...v0.2.1](https://github.com/marcelotto/sycamore/compare/v0.2.0...v0.2.1)



## 0.2.0 - 2016-04-05

### Added

- assigning `Sycamore::Nothing` via `Tree#[]=` removes a child tree
- `Tree#search` for searching the tree for one or multiple nodes or a tree
- `Tree#node!` as a more strict variant of `Tree#node`, which raises an error 
  when no node present

[Compare v0.1.0...v0.2.0](https://github.com/marcelotto/sycamore/compare/v0.1.0...v0.2.0)



## 0.1.0 - 2016-03-28

Initial release
