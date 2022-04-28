# frozen_string_literal: true

desc 'Creates a staging test token for API integration tests'
task mobile_test_tokens: :environment do
  if Settings.mobile_api.test_session_secret == 'fake_secret'
    raise "test_session_secret' env var not set in settings.local.yml"
  end

  file = Rails.root.join('modules', 'mobile', 'lib', 'tasks', 'support', 'test_users.yaml')
  users = YAML.load_file(file)['users']

  users.each do |user|
    user = user.symbolize_keys
    user = user.merge(
      uuid: SecureRandom.uuid,
      loa: {
        current: 3,
        highest: 3
      },
      sign_in: {
        service_name: 'oauth_IDME',
        account_type: '3'
      },
      expiration_timestamp: Time.now.to_i + 60 * 5
    )

    puts '---------------------------------------------------------------------'
    puts "#{user[:first_name]} #{user[:last_name]}"
    puts JWT.encode user, Settings.mobile_api.test_session_secret, 'HS256'
  end
end
