# -*- encoding: utf-8 -*-
# stub: sidekiq-limit_fetch 3.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq-limit_fetch".freeze
  s.version = "3.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["brainopia".freeze]
  s.date = "2016-10-13"
  s.description = "    Sidekiq strategy to restrict number of workers\n    which are able to run specified queues simultaneously.\n".freeze
  s.email = "brainopia@evilmartians.com".freeze
  s.homepage = "https://github.com/brainopia/sidekiq-limit_fetch".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Sidekiq strategy to support queue limits".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sidekiq>.freeze, [">= 4"])
      s.add_development_dependency(%q<redis-namespace>.freeze, ["~> 1.5", ">= 1.5.2"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<sidekiq>.freeze, [">= 4"])
      s.add_dependency(%q<redis-namespace>.freeze, ["~> 1.5", ">= 1.5.2"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<sidekiq>.freeze, [">= 4"])
    s.add_dependency(%q<redis-namespace>.freeze, ["~> 1.5", ">= 1.5.2"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
