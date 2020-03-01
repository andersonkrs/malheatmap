ENV["COVERAGE"] ||= "true"

require "simplecov"
require "simplecov-cobertura"

if ENV["COVERAGE"] == "true"
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ]

  SimpleCov.use_merging true
  SimpleCov.start do
    add_filter "config"
    add_filter "vendor"
    add_filter "bin"
    add_filter "db"
    add_filter "test"
  end
end
