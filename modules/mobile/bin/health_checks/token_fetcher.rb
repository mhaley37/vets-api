# frozen_string_literal: true

require 'capybara'
require 'yaml'

class TokenFetcher
  TOKEN_URL = 'https://va-mobile-cutter.herokuapp.com'
  USERS_FILE = ENV['STAGING_TEST_USERS']

  attr_reader :token

  def initialize(user_name)
    set_user(user_name)
    Capybara.default_max_wait_time = 5
    @session = Capybara::Session.new(:selenium_chrome_headless)
  end

  def fetch_token
    @session.visit TOKEN_URL
    @session.click_link('Please Login')
    @session.click_button('Sign in with ID.me')
    @session.click_button('Accept')
    @session.fill_in 'user_email', with: @user['email']
    @session.fill_in 'user_password', with: @user['password']
    @session.click_button('Sign in to ID.me')
    @session.click_button('Continue')
    @session.click_button('Continue')
    @session.click_button('Accept')
    @session.click_button('Auth')
    token_text = @session.find('div', text: /Access Token: ?/i).text
    @token = token_text.split[2]
    @session.driver.quit
  end

  def copy_token_to_clipboard
    IO.popen('pbcopy', 'w') { |pipe| pipe.puts token }
  end

  def set_user(user_name)
    @user = users_data[user_name]
    raise "User #{user_name} not found" unless @user
  end

  def users_data
    YAML.safe_load(File.read(USERS_FILE))
  end
end

if __FILE__ == $PROGRAM_NAME
  fetcher = TokenFetcher.new(ARGV[0])
  fetcher.fetch_token
  puts "TOKEN: #{fetcher.token}"
  fetcher.copy_token_to_clipboard
end
