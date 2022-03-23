require 'capybara'
require 'pry'
require 'yaml'

class TokenFetcher
  TOKEN_URL = 'https://va-mobile-cutter.herokuapp.com'
  USERS_FILE = 'modules/mobile/app/services/mobile/v0/sessions/login_users.yml'

  attr_reader :user_name, :token, :session

  def initialize(user_name)
    @user_name = user_name
    Capybara.default_max_wait_time = 5
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
    puts "found token: #{token}"
  end

  def copy_token_to_clipboard
    IO.popen('pbcopy', 'w') { |pipe| pipe.puts token }
  end

  # this should not be in this file
  def user
    @user ||= begin
      users = YAML.safe_load(File.read(USERS_FILE))
      users[user_name]
    end
  end
end

if __FILE__ == $0
  fetcher = TokenFetcher.new('judy')
  fetcher.fetch_token
  fetcher.copy_token_to_clipboard
end