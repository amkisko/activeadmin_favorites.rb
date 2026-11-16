# frozen_string_literal: true

require_relative "spec_helper"

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"

DUMMY_ROOT = Rails.root unless defined?(DUMMY_ROOT)

ActiveRecord::Base.connection_pool.with_connection do |connection|
  next if connection.table_exists?(:admin_favorites)

  ActiveRecord::Schema.verbose = false
  load DUMMY_ROOT.join("db", "schema.rb").to_s
end

require "rspec/rails"
require "factory_bot"
require "activeadmin"
require "capybara/rails"
require "capybara/rspec"
require "capybara-playwright-driver"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |path| require path }

ActiveAdmin::Favorites::Favorite.define_favorites_user_association!
ActiveAdmin::Favorites::ViewLensDefault.define_favorites_user_association!

Rails.application.reload_routes!
ActiveAdmin.application.load!

module AuthHelpers
  def sign_in(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include AuthHelpers, type: :request
  config.include AuthHelpers, type: :system
  config.include GraphqlRequestHelper, type: :request
  config.infer_spec_type_from_file_location!
  config.filter_run_when_matching :focus
  config.filter_rails_from_backtrace!
  config.order = :random
  Kernel.srand config.seed

  config.before(:each, type: :system) do
    skip PlaywrightEnv.hint unless PlaywrightEnv.cli_available?

    driven_by :playwright
  end
end

FactoryBot.define do
  factory :user do
    sequence(:email) { |index| "user-#{index}@example.com" }
  end

  factory :filters_favorite, class: "ActiveAdmin::Favorites::FiltersFavorite" do
    association :user
    sequence(:name) { |index| "Favorite #{index}" }
    resource_key { "articles" }
    path { "/admin/articles" }
    query_string { "order=id_desc" }
    published { false }
    macros { [] }
    macros_version { 1 }
  end
end
