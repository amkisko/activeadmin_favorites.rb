# frozen_string_literal: true

# Playwright driver (browser, headless, CLI path, timeout).
# System specs skip when PlaywrightEnv.cli_available? is false (rails_helper).
Capybara.save_path = ENV.fetch("CAPYBARA_ARTIFACTS", "log/capybara")
Capybara.default_max_wait_time = ENV.fetch("CAPYBARA_MAX_WAIT", "10").to_i
Capybara.server = :puma, {Silent: true}

headless = ENV["HEADFUL"].blank? || ENV["CI"].present?

Capybara.register_driver :playwright do |app|
  options = {
    browser_type: ENV.fetch("BROWSER", "chromium").to_sym,
    headless: headless
  }
  path = ENV["PLAYWRIGHT_CLI_EXECUTABLE_PATH"].to_s.strip
  options[:playwright_cli_executable_path] = path.empty? ? "npx playwright" : path
  Capybara::Playwright::Driver.new(app, **options)
end

Capybara.javascript_driver = :playwright
Capybara.app = Rails.application
