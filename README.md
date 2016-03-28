
# Sycamore

> _"The Egyptians' Holy Sycamore also stood on the threshold of life and death, connecting the two worlds."_  
>   -- [Wikipedia: Tree of Life](http://en.wikipedia.org/wiki/Tree_of_life)

[![Travis CI Build Status](https://secure.travis-ci.org/marcelotto/sycamore.png)](https://travis-ci.org/marcelotto/sycamore?branch=master)
[![Coverage Status](https://coveralls.io/repos/marcelotto/sycamore/badge.png)](https://coveralls.io/r/marcelotto/sycamore)
[![Inline docs](http://inch-ci.org/github/marcelotto/sycamore.png)](http://inch-ci.org/github/marcelotto/sycamore)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://rubydoc.org/gems/spread2rdf/frames)
[![Gitter Chat](http://img.shields.io/badge/chat-gitter.im-orange.svg)](https://gitter.im/marcelotto/sycamore)
[![License](http://img.shields.io/license/MIT.png?color=green)](http://opensource.org/licenses/MIT)

**Sycamore is an implementation of an unordered tree data structure.**

Features:

- easy, hassle-free access to arbitrarily deep nested elements
- grows automatically when needed
- familiar Hash interface
- no more `nil`-induced errors

Imagine a Sycamore tree as a recursively nested set. The elements of this set, called nodes, are associated with a child tree of additional nodes and so on. This might be different to your usual understanding of a tree, which has to have one single root node, but this notion is much more general. The usual tree is just a special case with just one node at the first level. But I prefer to think of the root to be implicit. Effectively every object is a tree in this sense. You can assume `self` to be the implicit root.

Restrictions:

- Only values you would use as keys of a hash should be used as nodes of a Sycamore tree. Although Ruby's official Hash documentation says *a Hash allows you to use any object type*, one is well advised [to use immutable objects only](http://jafrog.com/2012/10/07/mutable-objects-as-hash-keys-in-ruby.html). Enumerables as nodes are explicitly excluded by Sycamore.
- The nodes are unordered and can't contain duplicates.
- A Sycamore tree is uni-directional, i.e. has no relationship to its parent.

## Why

JSON, document-oriented databases, GraphQL and much more - trees in the sense of recursively nested sets are omnipresent today. But why then are there so few implementations of tree data structures? The answer is simple: because of Ruby's powerful built-in hashes. The problem is that while Ruby's Hash, as an implementation of the [Hash map data structure](https://en.wikipedia.org/wiki/Hash_table), might be perfectly fine for flat dictionary like structures, it is not very well-suited for storing tree structures. Ruby's hash literals, which allow it to easily nest multiple hashes, belie this fact. But it catches up when you want to build up a tree with hashes dynamically and have to manage the hash nesting manually.

In contrast to the few existing implementations of tree data structures in Ruby, Sycamores is based on Ruby's very efficient hashes and contains the values directly without any additional overhead. It only wraps the hashes itself. This wrapper object is very thin, containing nothing more than the hash itself. This comes at the price of the aforementioned restrictions, prohibiting it to be a general applicable tree implementation. But I hope to get around some of these restrictions in the future.

Another compelling reason for the use of Sycamore is its handling of `nil`. Much has [been](https://www.youtube.com/watch?v=OMPfEXIlTVE) [said](http://programmers.stackexchange.com/questions/12777/are-null-references-really-a-bad-thing) about the problem of `nil` (or equivalent null-values in other languages), including: ["It was my Billion-dollar mistake"](http://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare) from its founder, Tony Hoare. Every developer has experienced it in the form of errors such as 

```
NoMethodError: undefined method '[]' for nil:NilClass
```

With Sycamore this is a thing of the past.


## Supported Ruby versions

- MRI >= 2.1
- JRuby


## Dependencies

- none

## Installation

The recommended installation method is via [RubyGems](http://rubygems.org/).

    $ gem install sycamore


## Usage

I will introduce Sycamore's Tree API by comparing it with [Rubys native Hash API](http://ruby-doc.org/core-2.2.3/Hash.html).

In the following I'll always write `Tree` for the Sycamore tree class, instead of the fully qualified `Sycamore::Tree`. By default, this global `Tree` constant is not available. If you want this, you'll have to 

```ruby
require 'sycamore/extension'
``` 

When you can't or don't to want to have the `Tree` alias constant in the global namespace, but still want a short alternative name, you can alternatively

```ruby
require 'sycamore/stree'
``` 

to get an alias constant `STree` with less potential for conflicts.

I recommend trying the following code yourself in a Ruby REPL like [Pry](http://pryrepl.org).


### Creating trees

A `Sycamore::Tree` can be created similar to Hashes with the standard constructor or the class-level `[]` operator.

`Tree.new` creates an empty `Sycamore::Tree`.

```ruby
tree = Tree.new
tree.empty?  # => true
```

No additional arguments are supported at the time. As you'll see, for a `Sycamore::Tree` the functionality of the Hash constructor to specify the default value behaviour is of too little value to justify its use in the default constructor. The decision of its use can be tracked in [issue #1]().

The `[]` operator creates a new `Tree` and adds the arguments as its initial input. It can handle a single node value, a collection of nodes or a complete tree. 

```ruby
Tree[1]           # => #<Sycamore::Tree:0x3fcfe51a5a3c {1=>n/a}>
Tree[1, 2, 3]     # => #<Sycamore::Tree:0x3fcfe51a56f4 {1=>n/a, 2=>n/a, 3=>n/a}>
Tree[1, 2, 2, 3]  # => #<Sycamore::Tree:0x3fcfe51a52d0 {1=>n/a, 2=>n/a, 3=>n/a}>
Tree[x: 1, y: 2]  # => #<Sycamore::Tree:0x3fcfe51a4e34 {:x=>1, :y=>2}>
```

As you can see in line 3 nodes are stored as a set, i.e. with duplicates removed.

Note that multiple arguments are not interpreted as an associative array as `Hash[]` does, but rather as a set of leaves, i.e. nodes without children.

```ruby
Hash[1, 2, 3, 4]  # => {1=>2, 3=>4}
Hash[1, 2, 3]     # => ArgumentError: odd number of arguments for Hash
```

You can also see that children of leaves, i.e. nodes without children, are signified with `n/a`. When providing input data with Hashes, you can use `nil` as the child value of a leaf.

```ruby
Tree[x: 1, y: 2, z: nil]  
# => #<Sycamore::Tree:0x3fcfe51a4e34 {:x=>1, :y=>2, :z=>n/a}>
```

In general the `nil` child value for leaves in Hash literals is mandatory, but on the first level it can be ommitted, by providing the leaves as an argument before the non-leaf nodes.

```ruby
Tree[:a, :b, c: {d: 1, e: nil}]
# => #<Sycamore::Tree:0x3fd3f9c6bb0c {:a=>n/a, :b=>n/a, :c=>{:d=>1, :e=>n/a}}>
```

If you really want to have a node with `nil` as a child, you'll have to put the `nil` in an array.

```ruby
Tree[x: 1, y: 2, z: [nil]]  
# => #<Sycamore::Tree:0x3fd641858264 {:x=>1, :y=>2, :z=>nil}>
```


### Accessing trees

Access to elements of a `Sycamore::Tree` is mostly API-compatible to that of Rubys Hash class. But there is one major difference in the return type of most of the access methods: Since we are dealing with a recursively defined tree structure, the returned children are always trees as well.

The main method for accessing a tree is the `[]` operator.

```ruby
tree = Tree[x: 1, y: {2 => "a"}]

tree[:x]    # => #<Sycamore::Tree:0x3fea48d24d40 {1=>n/a}>
tree[:y]    # => #<Sycamore::Tree:0x3fea48d24b74 {2=>"a"}>
tree[:y][2] # => #<Sycamore::Tree:0x3fea48d248f4 {"a"=>n/a}>
```

The actual nodes of a tree can be retrieved with the method `nodes`.

```ruby
tree.nodes  # => [:x, :y]
tree[:x].nodes  # => [1]
tree[:y].nodes  # => [2]
tree[:y][2].nodes  # => ["a"]
```

If it's certain that a tree has at most one element, you can also use `node` to get that node directly.

```ruby
tree[:y].node     # => 2
tree[:y][2].node  # => "a"
tree[:x][1].node  # => nil
tree.node  # Sycamore::NonUniqueNodeSet: multiple nodes present: [:x, :y]
```

As opposed to Hash, the `[]` operator of `Sycamore::Tree` also supports multiple arguments which get interpreted as a path.

```ruby
tree[:y, 2].node  # => "a"
```

For compatibility with Ruby 2.3 hashes, this can also be done with the `dig` method.

```ruby
tree.dig(:y, 2).node  # => "a"
```

`fetch`, as a more controlled way to access the elements, is also supported.

```ruby
tree.fetch(:x)               # => #<Sycamore::Tree:0x3fea48d24d40 {1=>n/a}>
tree.fetch(:z)               # => KeyError: key not found: :z
tree.fetch(:z, :default)     # => :default
tree.fetch(:z) { :default }  # => :default
```

Fetching the child of a leaf behaves almost the same as fetching the child of a non-existing node, i.e. the default value is returned or a `KeyError` gets raised. In order to differentiate these cases, a `Sycamore::ChildError` as a subclass of `KeyError` is raised when accessing the child of a leaf.

The number of nodes of a tree can be determined with `size`. This will only count direct nodes.

```ruby
tree.size  # => 2
```

`total_size` or its short alias `tsize` returns the total number of nodes of a tree, including the nodes of children.

```ruby
tree.total_size  # => 5
tree[:y].tsize   # => 2
```

The height of a tree, i.e. the length of its longest path can be computed with  the method `height`.

```ruby
tree.height  # => 3
```

`empty?` checks if a tree is empty.

```ruby
tree.empty?         # => false
tree[:x, 1].empty?  # => true
```

`leaf?` checks if a node is a leaf.

```ruby
tree.leaf? :x     # => false
tree[:x].leaf? 1  # => true
```

`leaves?` (or one of its aliases `external?` and `flat?`) can be used to determine this for more nodes at once.

```ruby
Tree[1, 2, 3].leaves?(1, 2)  # => true
```

Without any arguments `leaves?` returns whether all nodes of a tree are leaves.

```ruby
Tree[1, 2].leaves?  # => true
```

`include?` checks whether one or more nodes are in the set of nodes of this tree.

```ruby
tree.include? :x        # => true
tree.include? [:x, :y]  # => true
```

`include?` can also check whether a tree structure (incl. a hash) is a sub tree of a `Sycamore::Tree`.

```ruby
tree.include?(x: 1, y: 2)  # => true
```


### Accessing absent trees

There is another major difference to a hash, which is in fact just a consequence of the already mentioned difference, that the access methods (except `fetch`) **always** return trees, when asked for children: They even return a child tree, when it does not exist. When you ask a hash for a non-existent element with the `[]` operator, you'll get a `nil`, which is an incarnation of the null-problem and the cause of many bug tracking sessions.

```ruby
hash = {x: 1, y: {2 => "a"}}
hash[:z]  # => nil
hash[:z][3]  # => NoMethodError: undefined method `[]' for nil:NilClass
```

Sycamore on the other side returns a special tree, the `Nothing` tree:

```ruby
tree = Tree[x: 1, y: {2 => "a"}]
tree[:z]     # => #<Sycamore::Nothing>
tree[:z][3]  # => #<Sycamore::Nothing>
```

`Sycamore::Nothing` is a singleton `Tree` implementing a [null object](https://en.wikipedia.org/wiki/Null_Object_pattern). It behaves on every query method call like an empty tree.

```ruby
Sycamore::Nothing.empty?  # => true
Sycamore::Nothing.size    # => 0
Sycamore::Nothing[42]     # => #<Sycamore::Nothing>
```

Sycamore adheres to a strict [command-query-separation (CQS)](https://en.wikipedia.org/wiki/Command%E2%80%93query_separation). A method is either a command changing the state of the tree and returning `self` or a query method, which only computes and returns the results of the query, but leaves the state unchanged. The only exception to this strict separation is made, when it is necessary in order to preserve hash compatibility. All query methods are supported by the `Sycamore::Nothing` tree with empty tree semantics.

Among the command methods are two subclasses: additive command methods, which add elements and destructive command methods, which remove elements. These are further refined into pure additive and pure destructive command methods, which either support additions or deletions only, not both operations at once. The `Sycamore::Tree` extends Ruby's reflection API with class methods to retrieve the respective methods: `query_methods`, `command_methods`, `additive_command_methods`, `destructive_command_methods`, `pure_additive_command_methods`, `pure_destructive_command_methods`.

```ruby
Tree.command_methods
# => [:add, :<<, :replace, :create_child, :[]=, :delete, :>>, :clear, :compact, :replace, :[]=, :freeze]
Tree.additive_command_methods
# => [:add, :<<, :replace, :create_child, :[]=]
Tree.pure_additive_command_methods
# => [:add, :<<, :create_child]
Tree.pure_destructive_command_methods
# => [:delete, :>>, :clear, :compact]
```

Pure destructive command methods on `Sycamore::Nothing` are no-ops. All other command methods raise an exception.

```ruby
Sycamore::Nothing.clear  # => #<Sycamore::Nothing>
Sycamore::Nothing[:foo] = :bar  
# => Sycamore::NothingMutation: attempt to change the Nothing tree
```

But inspecting the `Nothing` tree returned by `Tree#[]` further shows, that this isn't the end of the story.

```ruby
tree[:z].inspect
# => absent child of node :z in #<Sycamore::Tree:0x3fc88e04a470 {:x=>1, :y=>{2=>"a"}}>
tree[:z][3].inspect
# => absent child of node 3 in absent child of node :z in #<Sycamore::Tree:0x3fc88e04a470 {:x=>1, :y=>{2=>"a"}}>
```

We'll actually get an `Absence` object, a [proxy object](https://en.wikipedia.org/wiki/Proxy_pattern) for the requested not yet existing tree. As long as we don't try to change it, this `Absence` object delegates all method calls to `Sycamore::Nothing`. But as soon as we call a non-pure-destructive command method, the missing tree will be created, added to the parent tree and the method call gets delegated to the now existing tree.

```ruby
tree[:z] = 3
tree.to_h  # => {:x=>1, :y=>{2=>"a"}, :z=>3}
```

So a `Sycamore::Tree` is a tree, on which the nodes grow automatically, but only when needed. And this works recursively on arbitrarily deep nested absent trees.

```ruby
tree[:some][:very][:deep] = :node
tree.to_h  # => {:x=>1, :y=>{2=>"a"}, :z=>3, :some=>{:very=>{:deep=>:node}}}
```

In order to determine whether a node has no children, you can simply use `empty?`.

```ruby
tree = Tree[a: 1]
tree[:a].empty?  # => false
tree[:b].empty?  # => true  
```

But how can you distinguish an empty from a missing tree?

```ruby
user = Tree[name: 'Adam', shopping_cart_items: []]

user[:shopping_cart_items].empty?  # => true
user[:foo].empty?                  # => true
```

One way is the use of the `absent?` method, which only returns `true` on an `Absence` object.

```ruby
user[:shopping_cart_items].absent?  # => false
user[:foo].absent?                  # => true
```

Another possibility, without the need to create the `Absence` in the first place is the `leaf?` method, since it also checks for the presence of a node.

```ruby
user.leaf? :shopping_cart_items         # => true
user.leaf? :foo                         # => false
```

But the `leaf?` method has as similar problem in this respect: it doesn't differentiate between absent and empty children.

```ruby
tree = Tree[foo: nil, bar: []]
tree.leaf? :foo         # => true
tree.leaf? :bar         # => true
```

`strict_leaf?` and `strict_leaves?` (or their short aliases `sleaf?` and `sleaves?`) are more strict in this regard: when a node has an empty child tree it is considered a leaf, but not a strict leaf.

```ruby
tree.strict_leaf? :foo  # => true
tree.strict_leaf? :bar  # => false
```

Besides `absent?`, the congeneric methods `blank?` (as an alias of `empty?`) and its negation `present?` are ActiveSupport compatible available. Unfortunately, the natural expectation of `Tree#present?` and `Tree#absent?` to be mutually opposed leads astray.

```ruby
user[:shopping_cart_items].absent?   # => false
user[:shopping_cart_items].present?  # => false
```

The risks rising from an ActiveSupport incompatible `present?` is probably greater then this inconsistence. So, if you want check if a tree is not absent, use `existent?` as the negation of `absent?`.

Beside these options, `fetch` is also a method to handle this situation in a nuanced way.

```ruby
user.fetch(:shopping_cart_items)  # => #<Sycamore::Tree:0x3febb9c9b3d4 {}>
user.fetch(:foo)                            
# => KeyError: key not found: :foo
user.fetch(:foo, :default)  # => :default
```

Empty child trees also play a role when determining equality. The `eql?` and `==` equivalence differ exactly in their handling of this question: `==` treats empty child trees as absent trees, while `eql?` doesn't.

```ruby
Tree[:foo].eql? Tree[foo: []]  # => false
Tree[:foo] == Tree[foo: []]    # => true
```

All empty child trees can be removed with `compact`.

```ruby
Tree[:foo].eql? Tree[foo: []].compact  # => true
```

An arbitrary structure can be compared with a `Sycamore::Tree` for equality with `===`.

```ruby
Tree[:foo, :bar] === [:foo, :bar]      # => true
Tree[:foo, :bar] === Set[:foo, :bar]   # => true
Tree[:foo => :bar] === {:foo => :bar}  # => true
```


### Changing trees

Let's examine the command methods to change the contents of a tree. The `add` method or the `<<` operator as its alias allows the addition of one, multiple or a tree structure of nodes.

```ruby
tree = Tree.new
tree << 1
tree << [2, 3]
tree << {3 => :a, 4 => :b}
puts tree 
> Tree[1=>nil, 2=>nil, 3=>:a, 4=>:b]
```

The `[]=` operator is Hash-compatible supported.

```ruby
tree[5] = :c
puts tree 
> Tree[1=>nil, 2=>nil, 3=>:a, 4=>:b, 5=>:c]
```

Note that this is just an `add` with a previous call of `clear`, which deletes all elements of the tree. This means, you can safely assign another tree without having to think about object identity.

If you want to explicitly state, that a node doesn't have any children, you can specify it in the following equivalent ways.

```ruby
tree[:foo] = []
tree[:foo] = {}
```

Note that these values are interpreted similarly inside tree structures, i.e. empty Enumerables become empty child trees, while `Nothing` or `nil` are used as place holders for the explicit negation of a child.

```ruby
puts Tree[ a: { b: nil }, c: { d: []} ]
>Tree[:a=>:b, :c=>{:d=>[]}]
```

Beside the deletion of all elements with the already mentioned `clear` method, single or multiple nodes and entire tree structures can be removed with `delete` or the `>>` operator.

```ruby
tree >> 1
tree >> [2, 3]
tree >> {4 => :b}
puts tree 
> Tree[5=>:c, :foo=>[]]
```

When removing a tree structure, only child trees with no more existing nodes get deleted.

```ruby
tree = Tree[a: [1,2]]
tree >> {a: 1}
puts tree 
> Tree[:a=>2]

tree = Tree[a: 1, b: 2]
tree >> {a: 1}
puts tree 
> Tree[:b=>2]
```


### Iterating trees

The fundamental `each` and with that all Enumerable methods behave Hash-compatible.

```ruby
tree = Tree[ 1 => {a: 'foo'}, 2 => :b, 3 => nil ]
tree.each { |node, child| puts "#{node} => #{child}" }

> 1 => Tree[:a=>"foo"]
> 2 => Tree[:b]
> 3 => Tree[]
```

`each_path` iterates over all paths to leafs of a tree. 

```ruby
tree.each_path { |path| puts path }

> #<Path: /1/a/foo>
> #<Path: /2/b>
> #<Path: /3>
```

The paths are represented by `Sycamore::Path` objects and are basically an Enumerable of the nodes on the path, specifically optimized for the enumeration of the set of paths of a tree. It does this, by sharing nodes between the different path objects. This means in the set of all paths, every node is contained exactly once, even the internal nodes being part of multiple paths.

```ruby
Tree['some possibly very big data chunk' => [1, 2]].each_path.to_a
# => [#<Sycamore::Path["some possibly very big data chunk",1]>,
#     #<Sycamore::Path["some possibly very big data chunk",2]>]
```


## Getting help

- [RDoc](http://www.rubydoc.info/gems/sycamore/)
- [Gitter](https://gitter.im/marcelotto/sycamore)


## Contributing

see [CONTRIBUTING](CONTRIBUTING.md) for details.


## License and Copyright

(c) 2015-2016 Marcel Otto. MIT Licensed, see [LICENSE](LICENSE.TXT) for details.
