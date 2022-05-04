# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# DHP Seeds; Remove before merge to master

Device.create(name: 'Vendor 1')
Device.create(name: 'Vendor 2')
VeteranDeviceRecord.create(icn: 'user1', device_id: 1, active: true)
VeteranDeviceRecord.create(icn: 'user1', device_id: 2, active: false)


