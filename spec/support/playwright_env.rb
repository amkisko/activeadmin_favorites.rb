# frozen_string_literal: true

# Detect Playwright CLI (npx, local node_modules, or PLAYWRIGHT_CLI_EXECUTABLE_PATH).
# System specs use :playwright when the CLI is available; otherwise they skip with a hint.
require "open3"

module PlaywrightEnv
  module_function

  def cli_available?
    return @cli if defined?(@cli)

    @cli = detect
  end

  def hint
    "Playwright CLI not found. npm install playwright && npx playwright install chromium"
  end

  def detect
    executable_ok?(ENV["PLAYWRIGHT_CLI_EXECUTABLE_PATH"]) ||
      command_ok?("npx", "playwright", "--version") ||
      local_bin_ok?
  rescue Errno::ENOENT
    false
  end

  def executable_ok?(path)
    path = path.to_s.strip
    return false if path.empty?

    command_ok?(path, "--version")
  end

  def local_bin_ok?
    bin = Rails.root.join("node_modules/.bin/playwright")
    bin.file? && command_ok?(bin.to_s, "--version")
  end

  def command_ok?(*command)
    _out, status = Open3.capture2e(*command)
    status.success?
  end
end
