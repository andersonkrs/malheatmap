# -*- encoding: utf-8 -*-
# stub: raabro 1.1.6 ruby lib

Gem::Specification.new do |s|
  s.name = "raabro".freeze
  s.version = "1.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Mettraux".freeze]
  s.date = "2018-06-21"
  s.description = "A very dumb PEG parser library, with a horrible interface.".freeze
  s.email = ["jmettraux+flor@gmail.com".freeze]
  s.homepage = "http://github.com/floraison/raabro".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "a very dumb PEG parser library".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
    else
      s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
  end
end
