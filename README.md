
# Sycamore
Sycamore is an implementation of a [Tree data structure](http://en.wikipedia.org/wiki/Tree_(data_structure\)) of unordered values, solely based on Ruby's native Hash maps. 

It can be used as a more usable/pleasant/powerful alternative to a standard Ruby Hash (with `Sycamore::Tree`) or Struct/OpenStruct (with `Sycamore::Structure`) or a Set ... whenever all elements are value objects and the order of all elements is irrelevant. It tries to be as close to Ruby's language, spirit and standard library as possible, by being 100% compatible to Ruby's Hash, while using as little as possible overhead to a bare Hash, regarding speed and memory consumption. From a data structure standpoint, a `Sycamore::Tree` is nothing more than a wrapper around a Ruby `Hash`, with a special interpretation and some restrictions on its content. 
[The latter restrictions, by some required and some optional rules to follow. !?] 
[For some cases, it might have a slight/significant more memory consumption, when ... breite Trees]

A `Sycamore::Tree` interprets a Ruby Hash as a set of nodes and a mapping to potential child trees, i.e. other `Sycamore::Tree`s recursivly, containing nodes with more Sycamore trees etc., but the nesting is abstracted away. It provides a Ruby Hash compatible API, which controls the full life-cycle of a `Sycamore::Tree`, without having to take care or even notice the nesting (of Hashs via Trees). Sycamore has a notion of Absence, so the controlled life-cycle begins before the creation, so that Trees get created automatically, but only then, when absolutely required.


## Installation

With an installed version of Ruby, you can install Sycamore from your command line as a [Ruby gem](https://rubygems.org/gems/sycamore):

    $ gem install sycamore


## Usage

I recommend to try the following code for yourself and play around more with it, using a Ruby REPL, e.g. like [Pry](http://pryrepl.org).

    $ pry -r sycamore

Or better, you activate the optional Sycamore Ruby Extension, which allows you to use a `Sycamore::Tree` unqualified as `Tree`.

    $ pry -r sycamore/extension

To use `Sycamore::Tree` unqualified in your Ruby code, you have to require it in your code explicitly with this file.

```ruby
require 'sycamore/extension'
```

I hope to offer this extensions in a much less obtrusive way soon, by implementating them as Ruby 2 refinements. Watch the progress in [issue #?]().

But before we come to know the `Sycamore::Tree`, one aspect you should be aware of: Sycamore's application of CQS as a general pattern/idiom of method implementations to it's `Tree` class.


### Command-Query-Separation (CQS)

The instance methods of the `Sycamore::Tree` class are divided into two groups, for the two types of return type behaviour of the [CQS principle](http://martinfowler.com/bliki/CommandQuerySeparation.html):

- _Command methods_ of a `Tree` return `self` and go [Eastward](http://confreaks.tv/videos/rubyconf2014-eastward-ho-a-clear-path-through-ruby-with-oo). Above being idempotent regarding the return value by consistently returning `self`, all _command methods_ of a `Tree` are also idempotent with respect to the state of a `Tree`: many subsequent calls of the same method with the same args, don't change the state after the first call.
-  _Query methods_ of a `Tree` return the result of the query and don't change the state of the `Tree` at all.

### Method name conventions

Since operators don't support blocks, the `Tree` methods are implemented as ordinary methods and aliased to an operator. The operators are the prefered way of usage (at least, it's my taste and usage furtherhence), unless you need the block [or some other not available feature?].


### Tree creation

A `Sycamore::Tree` can be created manually with its constructor.

```ruby
tree = Tree.new # => #<Sycamore::Tree:0x0123456789abcd @map={}>
```

For convenience, the constructor with all its affordances can be used also with the `Sycamore.Tree()` factory function, which can be used unqualified also, when the `sycamore/extension` is activated.

```ruby
tree = Tree() # => #<Sycamore::Tree:0x007fa662ad17d0 @map={}>
```

Another option to create a tree is the Tree class method `[]`.

```ruby
tree = Tree[] # => #<Sycamore::Tree:0x007fa662ad17d0 @map={}>
```

But where now comes the announced life-cycle into play, that begins before the creation. For that, I have to comfort you, with the hint, that all subsequentially needed Tree creations to build up the intended tree structure, are done automatically when needed, and only when needed. Before we introduce that, we have to understand what a Tree consists of.

As you can see now, our created `Tree` is `empty?`

```ruby
tree.empty?  # => true
```

So, let's add some content by giving it some nodes ...


### Nodes

#### Introduction

Let's start our examination of the contents of `Tree`s by studying flat trees, containing leaves only, i.e. containing nodes without children only, so we can focus on the concept of nodes. This will allow us to move on familiar ground and compare it to another, simpler, but closely related data structure of the Ruby Standard Library: `Set`. A flat tree with leaves only, is equivalent to a Set in general and to Ruby's `Set` implementation in specific.

A tree without children is only a set of nodes. So, what is a node? In Sycamore, _node_ is only another word for _value_. In any place, you can replace the word 'node' with the word 'value' and vice versa. But I prefer the term `node` over `value` because it is more neutral, at least with less dissent connotations. For example, it sounds strange and unfamiliar to talk of properties or attributes as values. But that's also a valid tree structure of nodes. 

Now, a node is a value. But what do I mean by that. Technically, since `Tree`s are in fact just Ruby Hashes, it can be every object, that adheres the requirements for an object to be used as a hash key: It must provide a proper `hash` method implementation.

Let's see this in action.


#### API

You can add a node with `add_node`, like this

```ruby
tree.add_node(42) # => #<Sycamore::Tree:0x007fa662ad17d0 @map={42=>Nothing}>
```

and get the whole node set back with `nodes`, like that

```ruby
tree.nodes # => [42]
```

You can also add multiple nodes at once with `add_nodes`, by providing the nodes either as multiple arguments, or as a single `Enumerable` argument.

```ruby
tree.add_nodes [1, 2]  # => #<Sycamore::Tree:0x007fa662ad17d0 @map={42=>Nothing, 1=>Nothing, 2=>nil}>
tree.add_nodes(1, 2)   # does the same (by splatting the args)
tree.nodes             # => [42, 1, 2]
```

Nested collections are not supported by `add_nodes`.

```ruby
tree.add_nodes [1, [2, 3]]
# => ArgumentError: can't handle enumerable nodes
```

Another option for adding nodes is the `<<` operator. 

```ruby
tree << [1, 2] # => #<Sycamore::Tree:0x007fa662ad17d0 @map={42=>nil, 1=>nil, 2=>nil}>
```

This operator is an alias for the universal `add` method, which delegates to `add_nodes` unless the given value is a hash. 

You can also give a single node or an `Enumerable` of nodes to `new` (or the `Sycamore.Tree()` factory function), which will get delegated to `add_node` resp. `add_nodes` of the newly created `Tree`.

```ruby
Tree.new(42).nodes # => [42]
Tree(42).nodes     # does the same
Tree([1, 2]).nodes # => [1, 2]
```

Finally, you can use the `Tree.[]` class method, which allows to provide a set of node directly, instead requiring an explicit Array construction.

```ruby
Tree[1, 2].nodes # => [1, 2]
```

Now, we have filled a `Sycamore::Tree` with nodes. 

```ruby
tree.empty? # => false
tree.size   # => 3
```

What can we do with them? We can see if a tree includes a node with `include?`.

```ruby
...
```

TODO: We can remove nodes ...

TODO: We can enumerate them ...

But that wouldn't be much more, than using a plain `Set` from Ruby's Standard library, because we have no children, only leaves. 

```ruby
tree.leaves?           # a shortcut for  
tree.leaf?(tree.nodes) # => true
tree.children.empty?   # => true
```

Redundant with above:
But in fact, without children, you can use Sycamore `Tree`s as a full substitute of Rubys `Set`. It is API compatible and uses the same amount of memory in this case and [is as fast as it. TODO: make speed comparisons].



### Child trees

#### Introduction

There are two basic categories of nodes: A node with a child tree or a node without a child tree, i.e. a leaf node. A node with a child tree is connected with another `Sycamore::Tree` and so on, recursively, until we reach a leaf.

The connection of all nodes to their child tree is the `Hash` map of a `Sycamore::Tree` and everything a `Sycamore::Tree` consists of. 

The whole high-level child API are in fact only three methods, which also can be used via Ruby operators.

- `child` or `[]`
- `add` or `<<`
- `remove` or `>>`

These methods delegate to lower-level methods, depending on the arguments types. These lower-level methods further delegate to implementation-specific methods. For a description of this child API in detail, read its documentation [here](). 


#### API

##### Adding children with `add` or `<<`

You can add complex tree structure of nodes to a `Tree` with the already mentioned universal `add` method or `<<` operator. As discussed, `add` and `<<` applied on a simple value or a non-Hash-like Enumerable will add a single node or a set of nodes. Now, when you give it a Hash-like object, it will add a corresponding tree structure of nodes.

```ruby
root = Tree()
root << { property: "value" } # does the same
root.add property: "value"    # => <Tree:0x...>
root.nodes # => [:property]
```

As the `Tree` constructor and the `Tree()` factory function delegate to `add`, they can be used with a Hash-like structure, too.

```ruby
root = Tree(property: "value")
```

##### Hash-like structures

Before we look at the created child tree, let's discuss what is meant with the terms of Hash-like or non-Hash-like structures. 

TODO: ... 

If an object is Hash-like is determined by the module function `Tree.hash_like?`, which implements a heuristic. The details can be found in the documentation. I will simplify the ...



##### Getting a child with `child` or `[]`

To get the child tree of a node, simply give the node to `child` or the `[]` operator.

```ruby
root = Tree(1 => 2)
root.child(1) # => <Tree:0x...>
root[1]		  # does the same
root[1].nodes # => [2]
```

As you see, `child` and `<<` return another `Tree`. So, if you simply want to add some nodes as children to a single node, you can do that without a Hash-like structure like this:

```ruby
root = Tree(1)
root[1] << 2
root[1].nodes # => [2] 
root[1][2] << [3, 4]
```

But the just created `Tree` could be created simpler, even without a Hash-like structure. 

```ruby
root = Tree()
root[1][2] << [3, 4]
```

To understand why this works and we don't get an `undefined method '[]' for nil:NilClass` exception like you would for a Ruby Hash, we must look at how `child` or `[]` handle leaves? 

Also note, that `child` and `[]` support a second variant using `Path`s, which will be discussed later. This allows further simplifications when accessing deeper children.




### Absent trees and the `Nothing` tree

> "The Egyptians' Holy Sycamore also stood on the threshold of life and death, connecting the two worlds." - [Wikipedia](http://en.wikipedia.org/wiki/Tree_of_life)


### Trees as Enumerables

### Tree equivalence


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing


1. Fork it ( https://github.com/marcelotto/sycamore/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
