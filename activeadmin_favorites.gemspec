# frozen_string_literal: true

require_relative "lib/activeadmin/favorites/version"

Gem::Specification.new do |spec|
  spec.name = "activeadmin_favorites"
  spec.version = ActiveAdmin::Favorites::VERSION
  spec.authors = ["Andrei Makarov"]
  spec.email = ["contact@kiskolabs.com"]

  spec.summary = "Favorites and view lens personalization for ActiveAdmin 4"
  spec.description = "Saved filter bookmarks, per-resource layout preferences, and a cogwheel personalization UI for ActiveAdmin index and show pages."
  spec.license = "MIT"
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 3.4"

  repository_url = "https://github.com/amkisko/activeadmin_favorites.rb"

  spec.homepage = repository_url
  spec.metadata = {
    "homepage_uri" => repository_url,
    "source_code_uri" => "#{repository_url}/tree/main",
    "changelog_uri" => "#{repository_url}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{repository_url}/issues",
    "documentation_uri" => "#{repository_url}#readme",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.chdir(__dir__) do
    %w[
      CHANGELOG.md
      CODE_OF_CONDUCT.md
      CONTRIBUTING.md
      GOVERNANCE.md
      LICENSE.md
      README.md
      SECURITY.md
      activeadmin_favorites.gemspec
    ].select { |path| File.file?(path) } +
      Dir["{app,config,db,lib,sig}/**/*"]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "activeadmin", ">= 4.0.0.beta13", "< 5"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "rails", ">= 7.2"

  spec.add_development_dependency "factory_bot", "~> 6"
  spec.add_development_dependency "appraisal", "~> 2"
  spec.add_development_dependency "bundler-audit", "~> 0.9"
  spec.add_development_dependency "bundler", ">= 2"
  spec.add_development_dependency "polyrun", ">= 2.2.0"
  spec.add_development_dependency "prosopite", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "rspec-rails", ">= 6"
  spec.add_development_dependency "sqlite3", ">= 1"
  spec.add_development_dependency "rubocop-rails", "~> 2.34"
  spec.add_development_dependency "rubocop-rspec", "~> 3.8"
  spec.add_development_dependency "rubocop-thread_safety", "~> 0.7"
  spec.add_development_dependency "standard", "~> 1.52"
  spec.add_development_dependency "standard-custom", "~> 1.0"
  spec.add_development_dependency "standard-performance", "~> 1.8"
  spec.add_development_dependency "standard-rails", "~> 1.5"
  spec.add_development_dependency "standard-rspec", "~> 0.3"
  spec.add_development_dependency "rbs", "~> 4"
end
