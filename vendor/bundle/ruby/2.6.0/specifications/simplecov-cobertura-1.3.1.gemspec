# -*- encoding: utf-8 -*-
# stub: simplecov-cobertura 1.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "simplecov-cobertura".freeze
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jesse Bowes".freeze]
  s.date = "2019-04-02"
  s.description = "Produces Cobertura XML formatted output from SimpleCov".freeze
  s.email = ["jbowes@dashingrocket.com".freeze]
  s.homepage = "https://github.com/dashingrocket/simplecov-cobertura".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "SimpleCov Cobertura Formatter".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.2"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<simplecov>.freeze, ["~> 0.8"])
    else
      s.add_dependency(%q<test-unit>.freeze, ["~> 3.2"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<test-unit>.freeze, ["~> 3.2"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.8"])
  end
end
