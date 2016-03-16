# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


unless Rails.env.production?

  emails = [
    'archivist1@example.com',
    'archivist2@example.com',
    'dashboard@example.com',
    'reviewer1@example.com'
  ]
  
  emails.each do |email|   
    User.find_or_create_by(email: email) do |user|
      user.password = 'password'
    end  
  end
end

