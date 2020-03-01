# -*- encoding: utf-8 -*-
# stub: coercible 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "coercible".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Piotr Solnica".freeze]
  s.date = "2013-12-10"
  s.description = "Powerful, flexible and configurable coercion library. And nothing more.".freeze
  s.email = ["piotr.solnica@gmail.com".freeze]
  s.homepage = "https://github.com/solnic/coercible".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Powerful, flexible and configurable coercion library. And nothing more.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<descendants_tracker>.freeze, ["~> 0.0.1"])
    else
      s.add_dependency(%q<descendants_tracker>.freeze, ["~> 0.0.1"])
    end
  else
    s.add_dependency(%q<descendants_tracker>.freeze, ["~> 0.0.1"])
  end
end
