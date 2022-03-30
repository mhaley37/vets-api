desc "Explaining what the task does"
task :mobile_test_users do
  uuid = SecureRandom.uuid

  identity = IAMUserIdentity.new(
    uuid: uuid,
    first_name: 'HECTOR',
    middle_name: 'J',
    last_name: 'ALLEN',
    birth_date: '1932-02-05',
    iam_sec_id: '0000027792',
    icn: '1012667122V019349',
    gender: 'M',
    ssn: '796126859',
    email: 'vets.gov.user+0@gmail.com',
    loa: {
      current: LOA::THREE,
      highest: LOA::THREE
    }
  )
  identity.save
  
  user = IAMUser.build_from_user_identity(identity)
  user.save

  session = IAMSession.new(token: 'abc123', uuid: identity.uuid)
  session.save
  
  puts "do the thing #{user} #{session}"
end
