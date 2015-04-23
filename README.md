# Sycamore

Sycamore is an implementation of an unordered [Tree data structure](http://en.wikipedia.org/wiki/Tree_(data_structure)) of immutable values solely based on Ruby Hashes.

A Sycamore tree consists of a set of nodes and a mapping to child trees, i.e. other trees, containing nodes with more Sycamore trees ... 

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

I recommend to try the following code for yourself and play around more with a Ruby REPL, e.g. like [Pry](http://pryrepl.org).

    $ pry -r sycamore



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing


1. Fork it ( https://github.com/marcelotto/sycamore/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
