# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::ViewPaths do
  it "places favorites views before ActiveAdmin views" do
    favorites = ActiveAdmin::Favorites::Engine.root.join("app/views").to_s
    active_admin = Dir[
      File.expand_path("vendor/bundle/ruby/*/gems/activeadmin-*/app/views", Dir.pwd)
    ].first
    skip "ActiveAdmin gem views not found" unless active_admin

    host = Dir.mktmpdir("host-views")
    other = Dir.mktmpdir("other-views")
    path_set = ActionView::PathSet.new([host, active_admin, favorites, other])

    reordered = described_class.prefer_over_active_admin!(path_set)

    expect(reordered.to_a.map(&:to_s)).to eq([host, favorites, active_admin, other])
  ensure
    FileUtils.remove_entry(host) if host
    FileUtils.remove_entry(other) if other
  end

  it "keeps ActionController view paths ahead of ActiveAdmin for catalog injection" do
    paths = ActionController::Base.view_paths.to_a.map(&:to_s)
    favorites = ActiveAdmin::Favorites::Engine.root.join("app/views").to_s
    active_admin = paths.find { |path| path.match?(%r{/gems/activeadmin-[^/]+/app/views\z}) }

    expect(paths).to include(favorites)
    expect(active_admin).to be_present
    expect(paths.index(favorites)).to be < paths.index(active_admin)
  end
end
