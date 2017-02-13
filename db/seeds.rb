# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'ffaker'

# Tenants
10.times do
  Tenant.create(name: FFaker::Company.name)
end

# Users
users = []
20.times do
  users << User.create(name: FFaker::Name.name)
end

# Questions and Answers
20.times do
  question = Question.create(title: FFaker::HipsterIpsum.sentence.gsub(/\.$/, "?"),
    private: FFaker::Boolean.random, user: users.sample)
  (1 + rand(3)).times do
    question.answers.create(body: FFaker::HipsterIpsum.sentence, anonymous: FFaker::Boolean.random,user: users.sample)
  end
end

question = Question.create(
    title: "what's new with DOTA2 v7.0 updates?",
    private: false,
    user: users.sample)
question.answers.create( body: "wukong is so op!",
        user: users.sample,
        anonymous: false)
question.answers.create(   body: "have waited so many years",
    user: users.sample)
question.answers.create(
    body: "UI like LOL,TALENT like HOS",
    user: users.sample,
    anonymous: true)

question = Question.create(
        title:  "why did they always send 4396 when clearlove appeard ",
        private: true,
        user: users.sample)
(1 + rand(3)).times do
  question.answers.create(body: FFaker::HipsterIpsum.sentence, anonymous: FFaker::Boolean.random,user: users.sample)
end
