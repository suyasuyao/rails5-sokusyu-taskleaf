# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require_relative "headless.rb"

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end


Capybara.register_driver :remote_chrome do |app|
  url = "http://chrome:4444/wd/hub"

  #@headlessはheadless.rb内に定義する。
  if @headless || @headless.nil?
    caps_arg = [
      "no-sandbox",
      "headless",
      "disable-gpu",
      "window-size=1680,1050"
    ]
  else
    caps_arg = [
      "no-sandbox",
      "disable-gpu",
      "window-size=1680,1050"
    ]
  end

  caps = ::Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      "args" => caps_arg
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :remote, url: url, desired_capabilities: caps)
end

RSpec.configure do |config|

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :remote_chrome
    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
    Capybara.server_port = 3000
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
  end

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

end