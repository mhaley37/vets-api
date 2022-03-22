require 'capybara'
require 'pry'

TOKEN_URL = 'https://va-mobile-cutter.herokuapp.com'

session = Capybara::Session.new(:selenium)
session.visit TOKEN_URL
session.click_link('Please Login')
sleep 2 # not ideal but the first thing i've found that handles the redirects
session.click_button('Sign in with ID.me')
sleep 2
session.click_button('Accept')
sleep 2
session.fill_in 'user_email', :with => 'foo@bar.com' 
session.fill_in 'user_password', :with => 'secret'
#   click_on 'Sign in'
# end
