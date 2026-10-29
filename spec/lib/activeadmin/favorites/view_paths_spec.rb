# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::ViewPaths do
  def active_admin_views
    return unless defined?(::ActiveAdmin::Engine)

    ::ActiveAdmin::Engine.root.join("app/views").to_s
  end

  def path_set_for(*roots)
    ActionView::PathSet.new(roots)
  end

  it "places favorites views immediately before ActiveAdmin views" do
    favorites = ActiveAdmin::Favorites::Engine.root.join("app/views").to_s
    active_admin = active_admin_views
    skip "ActiveAdmin::Engine views not found" unless active_admin

    host = Dir.mktmpdir("host-views")
    other = Dir.mktmpdir("other-views")

    reordered = described_class.prefer_over_active_admin!(
      path_set_for(host, active_admin, favorites, other)
    )

    expect(reordered.to_a.map(&:to_s)).to eq([host, favorites, active_admin, other])
  ensure
    FileUtils.remove_entry(host) if host
    FileUtils.remove_entry(other) if other
  end

  it "moves prepended favorites behind host even when an activeadmin-* sibling is ahead" do
    favorites = ActiveAdmin::Favorites::Engine.root.join("app/views").to_s
    active_admin = active_admin_views
    skip "ActiveAdmin::Engine views not found" unless active_admin

    host = Dir.mktmpdir("host-views")
    sibling_home = Dir.mktmpdir("sibling-gem")
    sibling = File.join(sibling_home, "gems/activeadmin-command_palette-0.1.8/app/views")
    FileUtils.mkdir_p(sibling)

    reordered = described_class.prefer_over_active_admin!(
      path_set_for(favorites, sibling, host, active_admin)
    )

    expect(reordered.to_a.map(&:to_s)).to eq([sibling, host, favorites, active_admin])
  ensure
    FileUtils.remove_entry(host) if host
    FileUtils.remove_entry(sibling_home) if sibling_home
  end

  it "does not treat activeadmin-* sibling gems as ActiveAdmin views roots" do
    sibling = "/vendor/bundle/ruby/3.4.0/gems/activeadmin-command_palette-0.1.8/app/views"
    real = "/vendor/bundle/ruby/3.4.0/gems/activeadmin-4.0.0.beta23/app/views"

    allow(described_class).to receive(:active_admin_engine_views_root).and_return(nil)

    expect(described_class.send(:active_admin_views_root, [sibling, real])).to eq(real)
    expect(described_class.send(:active_admin_views_root, [sibling])).to be_nil
  end

  it "places ActionController favorites views immediately before ActiveAdmin" do
    paths = ActionController::Base.view_paths.to_a.map(&:to_s)
    favorites = ActiveAdmin::Favorites::Engine.root.join("app/views").to_s
    active_admin = active_admin_views

    expect(paths).to include(favorites)
    expect(active_admin).to be_present
    expect(paths.index(favorites)).to eq(paths.index(active_admin) - 1)
  end

  it "keeps dummy host views ahead of favorites after install" do
    paths = ActionController::Base.view_paths.to_a.map(&:to_s)
    favorites = ActiveAdmin::Favorites::Engine.root.join("app/views").to_s
    host = Rails.root.join("app/views").to_s

    expect(paths).to include(host)
    expect(paths.index(host)).to be < paths.index(favorites)
  end
end
