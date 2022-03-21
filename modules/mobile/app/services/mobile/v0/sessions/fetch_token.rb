require 'capybara'

TOKEN_URL = 'https://va-mobile-cutter.herokuapp.com'

session = Capybara::Session.new(:selenium)
session.visit TOKEN_URL
session.click_link('Please Login')
wait_until_scope_exists '.btn_idme3' do
  session.click_link()
end
#   fill_in 'Email', :with => 'foo@bar.com' 
#   fill_in 'Password', :with => 'secret'
#   click_on 'Sign in'
# end
binding.pry

# session.find('#sign-in-email').set(ENV.fetch('EMAIL'))
# session.find(:xpath, '//input[@type="password"]').set(ENV.fetch('PASSWORD'))
# session.find('.hw-btn-primary').click
# session.all('.confirmation-code').each do |code|
#   puts code.text
# end