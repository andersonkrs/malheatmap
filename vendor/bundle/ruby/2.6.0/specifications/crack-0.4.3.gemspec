# -*- encoding: utf-8 -*-
# stub: crack 0.4.3 ruby lib

Gem::Specification.new do |s|
  s.name = "crack".freeze
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Nunemaker".freeze]
  s.date = "2015-12-02"
  s.description = "Really simple JSON and XML parsing, ripped from Merb and Rails.".freeze
  s.email = ["nunemaker@gmail.com".freeze]
  s.homepage = "http://github.com/jnunemaker/crack".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Really simple JSON and XML parsing, ripped from Merb and Rails.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<safe_yaml>.freeze, ["~> 1.0.0"])
    else
      s.add_dependency(%q<safe_yaml>.freeze, ["~> 1.0.0"])
    end
  else
    s.add_dependency(%q<safe_yaml>.freeze, ["~> 1.0.0"])
  end
end
