# codeclimate-engine-rb

A simple way to create issues in the JSON format described in the [Code Climate Engine specification].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'codeclimate_engine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codeclimate_engine

## Usage

```ruby
location = CCEngine::Location::LineRange.new(
  path:       "foo/bar.txt",
  line_range: 13..14
)

issue = CCEngine::Issue.new(
  check_name:  "Bug Risk/Unused Variable",
  description: "Unused local variable `foo`",
  categories:  [CCEngine::Category.complexity, CCEngine::Category.style],
  location:    location
)

issue.to_json
```

The result would be:

```json
{
  "type": "issue",
  "check_name":  "Bug Risk/Unused Variable",
  "description": "Unused local variable `foo`",
  "categories":  ["Complexity", "Style"],
  "location": {
    "path": "foo/bar.txt",
    "lines": {
      "begin": 13,
      "end":   14
    }
  }
}
```

There are some other ways to specify the location – please browse the gem's
tests for details.

Code Climate requires that each issue is terminated with a null character.
Calling `render` on an issue will output the issue's JSON, followed by a null
character.

## Code Climate engines using this gem

* [Reek](https://github.com/troessner/reek)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/andyw8/codeclimate-engine-rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[Code Climate Engine specification]: https://github.com/codeclimate/spec/blob/master/SPEC.md
