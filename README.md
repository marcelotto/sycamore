# Sycamore

Sycamore is an implementation of an unordered [Tree data structure](http://en.wikipedia.org/wiki/Tree_(data_structure\)) of immutable values, solely based on Ruby's native Hashes. From a data structure standpoint a `Sycamore::Tree` is nothing more than a wrapper around a Ruby Hash map, with a special interpretation and some restrictions on its content. The latter restrictions, by some required and some optional rules to follow. 

A `Sycamore::Tree` interprets it's Ruby Hash as a set of nodes and a mapping to potential child trees, i.e. other `Sycamore::Tree`s recursivly, containing nodes with more Sycamore trees etc. This interpretation is implemented with behaviour in command- and query-separated methods, which abstracts away the nestedness. Thus providing an API to control the full life-cycle of a `Sycamore::Tree`, without having to take care or even notice of the nesting (with nested Hashs via Trees). 

And, since Sycamore has a notion of Absence, the controlled life-cycle begins before the creation of a Tree.


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

I hope to offer this extensions in a much less aggressive way soon, by implementating them as Ruby 2 refinements. Watch the progress in [issue #1]().

But before we come to know the `Sycamore::Tree`, one aspect you should be aware of: Sycamore's application of CQS as a general pattern/idiom of method implementations to it's `Tree` class.


### Command-Query-Separation (CQS)

The instance methods of the `Sycamore::Tree` class are divided into two groups, for the two types of return type behaviour of the [CQS principle]():

- _Command methods_ of a `Tree` return `self` and go [Eastward](). Above being idempotent regarding the return value by consistently returning `self`, all _command methods_ of a `Tree` are also idempotent with respect to the state of a `Tree`: many subsequent calls of the same method with the same args, don't change the state after the first call.
-  _Query methods_ of a `Tree` return the result of the query and don't change the state of the `Tree` at all.


### Tree creation

A `Sycamore::Tree` can be created manually with its constructor.

```ruby
  tree = Tree.new
```

For convenience, the constructor with all its affordances can be used also with the `Sycamore.Tree()` factory function, which can be used unqualified also, when the `sycamore/extension` is activated.

```ruby
  tree = Tree()
```

But where now comes the announced life-cycle into play, that begins before the creation. For that, I have to comfort you, with the hint, that all subsequentially needed Tree creations to build up the intended tree structure, are done automatically when needed, and only when needed. Before we introduce that, we have to understand what a Tree consists of.

As you can see now, our created `Tree` is `empty?`

```ruby
  tree.empty?  # => true
```

So, let's add some content by giving it some nodes ...


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing


1. Fork it ( https://github.com/marcelotto/sycamore/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
