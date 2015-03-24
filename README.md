# Sycamore

Sycamore is a pure Ruby implementation of a tree data structure, based entirely on a single nested Ruby `Hash`, which contains further trees recursively.


## Introduction

A `Sycamore::Tree` consists of a set of nodes and a mapping to child trees, i.e. other `Sycamore::Tree`s, containing `nodes` with more `Sycamore::Tree`s ... 

And from a data point of view, that's all: A `Sycamore::Tree` is nothing more than a wrapper around a Ruby `Hash` with a restriction on its value set: the values of the `Hash` are `Sycamore::Tree`s. For this specific semantics of a Ruby `Hash`, it provides a tree API.

### Nodes

The first thing, of what we have conceptually, is a set of nodes. This set of nodes is only the key set of the Ruby `Hash` (i.e. it's `Hash#key`s). The elements of this key set are called nodes.

A node is a value object. This means with Sycamore, your trees can consist only of value objects. To be clear: _You should not try to put any objects in it, which you wouldn't put in a Ruby `Hash` as a key._
  
So, in a `Sycamore::Tree`, _node_ is only another word for _value_, in any place, you can replace the word 'node' with the word 'value' and vice versa.


### Child trees

There are two types of nodes: A node with a child tree or a node without a child tree, i.e. a leaf node.

The child trees are therefore recursivly nested `Sycamore::Tree`s.


### The `Nothing` tree

The `Nothing` tree is a Singleton Null tree.

When you request the child tree of a leaf, you will get special [Singleton]() tree (via the later described API): the `Nothing` tree, which is a [Ruby Singleton]() `Sycamore::Tree`. The `Nothing` tree IS NOT the empty tree, like the empty set of set theory. It is a [Null object]() for which every call 

- will generate a Ruby `Binding` on "the context of the current request" and 
- [Ruby Fibers]()
	- What does the Fiber block do? Who creates it? Who defines it? Who determines the behaviour?
	- Why a Fiber and not simply a block?


The `Nothing` tree is a Singleton Null tree.

(So, `empty?` won't return true, but as every other method call on




### Equality
  
Before we move on to the usage, lets clarify the definition of the Ruby equality operators for `Sycamore::Tree`s.

The comparison of two `Sycamore::Tree`s with `==`, only checks for value equivalence of the node sets, but that recursively over the node sets of all of his child trees. 

If you want to compare two `Sycamore::Tree`s for Ruby object identity, use `equal?`. 

(Although you can also use `eql?` to do this identity comparison currently, this might not be the case in the future, where it might be redefined. For example, to compare for object identity, but only on the child trees.)


### Command-Query-Separation (CQS)

The methods of the `Sycamore::Tree` API are divided into two groups, for the two types of return type behaviour:

- a query method always returns the result of the query
- a command method always returns `self` (and goes [Eastward]())

But the return type behaviour can be switched via "Plugins":

- Promises
- HTTP reponses 
- ...


### Roots

Finally, you might ask yourself: A tree has a root. Where is the root stored? Why isn't there any `root` attribute? 

The usual _"root"_  of a `Sycamore::Tree` is not stored in a `Sycamore::Tree`. In fact, it even doesn't have to be a `Sycamore::Tree`. The root can be every object, which contains a `Sycamore::Tree` as an instance variable.

But, if you really want a root with `Sycamore`, create a `Sycamore::Tree` with a single node and child tree.



## Usage

### Tree creation

When you create a `Sycamore::Tree` with

```ruby
  include Sycamore
  
  tree = Tree.new
```

you can get the set of nodes with

```ruby
  tree.nodes  # => []
```

Another way to create a `Tree` is with the  `Sycamore.Tree()` function.

```ruby
  extend Sycamore
  
  tree = Tree()
```

It simple delegates all arguments to `Tree.new`, meaning all the discussed features of `new`, are also supported by this function.

As you can see, after creation, a `Tree` is `empty?`

```ruby
  tree.empty?  # => true
```

So, we must add some nodes ...


### Tree node API

You can add a node with `add_node` and get the whole node set with `nodes`.

```ruby
  tree.add_node(42)
  tree.nodes  # => [42]
```

You can add also add multiple nodes at once, with `add_nodes`, by giving the nodes either directly as arguments or as a single `Enumerable`.

```ruby
  tree.add_nodes(1, 2)
  tree.add_nodes [1, 2]
  tree.nodes  # => [42, 1, 2]
```

Note, that nested collections are not supported.

```ruby
  tree.add_nodes [1, [2, 3]]
  > ArgumentError: can't handle complex Enumerables
```

You can also give a single node or an `Enumerable` of nodes to `new` (or the `Sycamore.Tree()` function), which will get delegated to `add_node` resp. `add_nodes` of the newly created `Tree`.

```ruby
  Tree(42).nodes # => [42]
  Tree([1, 2]).nodes # => [1, 2]
  # or also: Tree(1, 2).nodes # => [1, 2]   # ?
```

Since it is a set, the ordering of the nodes is irrelevant.

```ruby
  Tree(1, 2) == Tree(2, 1) # => true
```

Now, we have filled a `Sycamore::Tree` with nodes. 

```ruby
  tree.empty? # => false
  tree.size # => 3
```


But that wouldn't be much more, than using a plain `Set` from Ruby's Standard library (which, by the way, is also implemented as a wrapper around a single `Hash`).

We have to do a little more, to get the benefits of a `Sycamore::Tree`, since we don't have any `children`.


```ruby
  tree.children.empty? # => true
```



### Tree children API

You can a add a single child tree to a single node using `add_child` and get the child tree of a node with `child`:

```ruby
tree.add_child(1 => 2)
tree.child(1) # => Tree(2)
```

While `add_child` takes a `Hash`, `child` returns a `Tree` ... 


The given child tree is a plain Ruby `Hash` literal, which can be complex. But if you have the intention to add a set of child trees, use the `add_children` alias of `add_child`.

To get the children of a set of nodes, you have to use `children` and give it multiple nodes as arguments:

```ruby
tree.add_children(
	1 => 2, 
	3 => { 4 => 5 }
)
tree.children(1, 3)
# => {1 => Tree(2), 3 => Tree(4 => 5)}
```

You can also call `new` (or the `Tree()` function) with a `Hash`, which gets passed to `add_children` on the created `Tree`.

```ruby
Tree(1 => 2, 3 => { 4 => 5 })
```

To get the whole mapping of all nodes to children, you could write `tree.children(*tree.nodes)`, but for that, there is an easier and faster way, by calling `children` without arguments:

```ruby
tree.children
# => {1 => 2, 3 => {4 => 5}}
```

The returned `Hash` is a deep copy of the wrapped Ruby `Hash`.
The `to_h` method of Ruby's object protocol is only an alias of `children` of this variant. 

[No, the argument-less version should delegate to `to_h`, which further delegates to `clone`.]



Finally, a little syntactic sugar: 

- `get` can be used via Ruby's `[]` operator
```ruby
  tree << 1
  tree << [2, 3]
```

- `add` can be used via Ruby's `<<` operator
```ruby
  tree << 1 
  tree << [2, 3]
  tree << {4 => 5}
```

- and `add_child` can also be used via Ruby's `[]=` operator
```ruby
  tree[1] = 2
  tree[1] = {2 => 3} 
```




### Trees as Enumerables

A `Sycamore::Tree` is an Enumerable of the node set:

```ruby
  tree = Tree.new.add_nodes('Hello', 'World')
  tree.each { |node| print node }
  # > HelloWorld
```

#### Or should it also provide the correspondig tree, when given a second arg?

You can also use the generic `add` method. It delegates a simple value to `add_node` and an array to `add_nodes`.

```ruby
  tree.add(1)
  tree.add([2, 3])
```

This generic `add` method, supports also another call mode. But for that, we first have to look at the children of the nodes.


### "Visitor Lambdas" on Trees





## Example trees

### Binary tree with numbers


```ruby
require 'sycamore'
require 'awesome_print'

include Sycamore

tree = Tree
tree << 1
tree[1] << [2, 3]
tree[1][2] << [4, 5]
tree[1][3] << [5, 6]
ap tree
tree.to_dot
```

![Result of tree.to_dot('bin-tree-with-numbers.png')](image-of-the-defined-tree-generated-with-dot "dot visualization of the tree")


### Pascal's triangle

```ruby
require 'sycamore'
require 'awesome_print'

include Sycamore

tree = Tree
# TODO (with blocks on enumerator methods)
tree.to_dot
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sycamore'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sycamore


## Usage


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing


1. Fork it ( https://github.com/marcelotto/sycamore/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
