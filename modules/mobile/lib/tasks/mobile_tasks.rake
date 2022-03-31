desc "Explaining what the task does"
task :mobile_test_users do
  uuid = SecureRandom.uuid

  identity = IAMUserIdentity.new(
    birth_date: '1932-02-05',
    email: 'vets.gov.user+0@gmail.com',
    expiration_timestamp: Time.now.to
    first_name: 'HECTOR',
    gender: 'M',
    iam_sec_id: '0000027792',
    icn: '1012667122V019349',
    last_name: 'ALLEN',
    loa: {
      current: LOA::THREE,
      highest: LOA::THREE
    },
    middle_name: 'J',
    ssn: '796126859',
    uuid: uuid
  )
  identity.save
  
  user = IAMUser.build_from_user_identity(identity)
  user.save

  session = IAMSession.new(token: 'abc123', uuid: identity.uuid)
  session.save
  
  puts "do the thing #{user} #{session}"
end
