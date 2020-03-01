# -*- encoding: utf-8 -*-
# stub: ice_nine 0.11.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ice_nine".freeze
  s.version = "0.11.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dan Kubb".freeze]
  s.date = "2016-01-29"
  s.description = "Deep Freeze Ruby Objects".freeze
  s.email = ["dan.kubb@gmail.com".freeze]
  s.extra_rdoc_files = ["LICENSE".freeze, "README.md".freeze, "TODO".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze, "TODO".freeze]
  s.homepage = "https://github.com/dkubb/ice_nine".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Deep Freeze Ruby Objects".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.6", ">= 1.6.1"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.6", ">= 1.6.1"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.6", ">= 1.6.1"])
  end
end
