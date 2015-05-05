# Sycamore

Sycamore is an implementation of an unordered [Tree data structure](http://en.wikipedia.org/wiki/Tree_(data_structure\)) of immutable values, solely based on Ruby Hashes.

A Sycamore tree interprets it's Ruby Hash as a set of nodes and a mapping to child trees, i.e. other trees, containing nodes with more Sycamore trees etc. 

And from a data point of view, that's all: A Sycamore tree is nothing more than a wrapper around a Ruby Hash map with a special restriction on its value set: the values of the Hash are Sycamore trees. For this specific semantics, Sycamore provides an API. As the keys of a Ruby Hash should be immutable values, there is also the restriction, that the nodes should be immutable values. 



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

I recommend to try the following code for yourself and play around more with it, using a Ruby REPL, e.g. like [Pry](http://pryrepl.org).

    $ pry -r sycamore

But before we begin to demonstrate the usage of `Sycamore::Tree`, one simple thing you should be aware of: a general pattern used for the implementation of the one and only class of Sycamore.


### Command-Query-Separation (CQS)

The methods of the `Sycamore::Tree` class are divided into two groups, for the two types of return type behaviour of its methods:

- All _command methods_ of a `Tree` return `self` and go [Eastward](). Above being idempotent regarding the return value by that, all _command methods_ of a `Tree` are also idempotent with respect to the state of a `Tree`: many subsequent calls of the same method with the same args, don't change the state after the first call.
- All _query method_ of a `Tree` return the result of the query and don't change the state of the `Tree` at all.



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing


1. Fork it ( https://github.com/marcelotto/sycamore/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
