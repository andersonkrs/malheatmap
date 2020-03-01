# -*- encoding: utf-8 -*-
# stub: virtus 1.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "virtus".freeze
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Piotr Solnica".freeze]
  s.date = "2015-03-18"
  s.description = "Attributes on Steroids for Plain Old Ruby Objects".freeze
  s.email = ["piotr.solnica@gmail.com".freeze]
  s.extra_rdoc_files = ["LICENSE".freeze, "README.md".freeze, "TODO.md".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze, "TODO.md".freeze]
  s.homepage = "https://github.com/solnic/virtus".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Attributes on Steroids for Plain Old Ruby Objects".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<descendants_tracker>.freeze, ["~> 0.0", ">= 0.0.3"])
      s.add_runtime_dependency(%q<equalizer>.freeze, ["~> 0.0", ">= 0.0.9"])
      s.add_runtime_dependency(%q<coercible>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<axiom-types>.freeze, ["~> 0.1"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<descendants_tracker>.freeze, ["~> 0.0", ">= 0.0.3"])
      s.add_dependency(%q<equalizer>.freeze, ["~> 0.0", ">= 0.0.9"])
      s.add_dependency(%q<coercible>.freeze, ["~> 1.0"])
      s.add_dependency(%q<axiom-types>.freeze, ["~> 0.1"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<descendants_tracker>.freeze, ["~> 0.0", ">= 0.0.3"])
    s.add_dependency(%q<equalizer>.freeze, ["~> 0.0", ">= 0.0.9"])
    s.add_dependency(%q<coercible>.freeze, ["~> 1.0"])
    s.add_dependency(%q<axiom-types>.freeze, ["~> 0.1"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
