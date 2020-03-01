# -*- encoding: utf-8 -*-
# stub: shoulda-context 1.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "shoulda-context".freeze
  s.version = "1.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["thoughtbot, inc.".freeze, "Tammer Saleh".freeze, "Joe Ferris".freeze, "Ryan McGeary".freeze, "Dan Croak".freeze, "Matt Jankowski".freeze]
  s.date = "2016-11-07"
  s.description = "Context framework extracted from Shoulda".freeze
  s.email = "support@thoughtbot.com".freeze
  s.executables = ["convert_to_should_syntax".freeze]
  s.files = ["bin/convert_to_should_syntax".freeze]
  s.homepage = "http://thoughtbot.com/community/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Context framework extracted from Shoulda".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<appraisal>.freeze, ["~> 0.5"])
      s.add_development_dependency(%q<rails>.freeze, [">= 3.0"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0.9.10"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<test-unit>.freeze, ["~> 2.1.0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
    else
      s.add_dependency(%q<appraisal>.freeze, ["~> 0.5"])
      s.add_dependency(%q<rails>.freeze, [">= 3.0"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0.9.10"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<test-unit>.freeze, ["~> 2.1.0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<appraisal>.freeze, ["~> 0.5"])
    s.add_dependency(%q<rails>.freeze, [">= 3.0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.9.10"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 2.1.0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
  end
end
