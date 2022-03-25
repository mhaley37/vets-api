# frozen_string_literal: true

require 'capybara'
require 'pry'
require 'yaml'

class TokenFetcher
  TOKEN_URL = 'https://va-mobile-cutter.herokuapp.com'
  USERS_FILE = ENV['STAGING_TEST_USERS']

  attr_reader :user, :token, :session

  def initialize(user_name)
    set_user(user_name)
    Capybara.default_max_wait_time = 10
    @session = Capybara::Session.new(:selenium)
  end

  def fetch_token
    session.visit TOKEN_URL
    session.click_link('Please Login')
    sleep 3 # this sleep appears to be necessary for dealing with the redirect
    session.click_button('Sign in with ID.me')
    session.click_button('Accept')
    session.fill_in 'user_email', with: user['email']
    session.fill_in 'user_password', with: user['password']
    session.click_button('Sign in to ID.me')
    session.click_button('Continue')
    session.click_button('Continue')
    session.click_button('Accept')
    session.click_button('Auth')
    token_text = session.find('div', text: /Access Token: ?/i).text
    @token = token_text.split[2]
  end

  def copy_token_to_clipboard
    IO.popen('pbcopy', 'w') { |pipe| pipe.puts token }
  end

  # this should not be in this file
  def set_user(user_name)
    @user = users_data[user_name]
    raise 'User not found' unless @user
  end

  # do this by environment variable instead
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
