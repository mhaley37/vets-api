# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# DHP Seeds; Remove before merge to master

device1 = Device.create(name: 'Vendor 11', key:'vendor-11')
device1_id = device1.id
device2 = Device.create(name: 'Vendor 22', key:'vendor-22')
device2_id = device2.id

VeteranDeviceRecord.create(icn: '8f683e74-cb11-4d11-94a3-ea97ad8723db', device_id: device1_id , active: true)
VeteranDeviceRecord.create(icn: '8f683e74-cb11-4d11-94a3-ea97ad8723db', device_id: device2_id, active: false)


