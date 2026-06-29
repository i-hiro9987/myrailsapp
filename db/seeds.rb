# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

user1 = User.find_or_create_by!(provider: "github", uid: "1001") do |u|
  u.name = "alice"
  u.image_url = "https://avatars.githubusercontent.com/u/1001"
end

user2 = User.find_or_create_by!(provider: "github", uid: "1002") do |u|
  u.name = "bob"
  u.image_url = "https://avatars.githubusercontent.com/u/1002"
end

event1 = Event.find_or_create_by!(name: "Rails勉強会 Vol.1") do |e|
  e.owner = user1
  e.place = "東京都渋谷区"
  e.content = "Rails 8の新機能について学ぶ勉強会です。初心者歓迎！"
  e.start_at = 1.week.from_now
  e.end_at = 1.week.from_now + 2.hours
end

event2 = Event.find_or_create_by!(name: "Ruby meetup") do |e|
  e.owner = user2
  e.place = "大阪府大阪市"
  e.content = "Rubyistが集まる月次ミートアップ。LT大歓迎！"
  e.start_at = 2.weeks.from_now
  e.end_at = 2.weeks.from_now + 3.hours
end

event3 = Event.find_or_create_by!(name: "Hotwire入門ハンズオン") do |e|
  e.owner = user1
  e.place = "オンライン"
  e.content = "Turbo・Stimulusを使ったモダンなRails開発を体験しよう。"
  e.start_at = 3.weeks.from_now
  e.end_at = 3.weeks.from_now + 2.hours
end

Ticket.find_or_create_by!(event: event1, user: user2) do |t|
  t.comment = "楽しみにしています！"
end

Ticket.find_or_create_by!(event: event2, user: user1) do |t|
  t.comment = "よろしくお願いします"
end

puts "Seeded: #{User.count} users, #{Event.count} events, #{Ticket.count} tickets"
