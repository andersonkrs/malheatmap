user = User.create!(
  username: "andersonkrs",
  avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg?t=1579970400"
)

items = [
  Item.create!(mal_id: 1, name: "Monster", kind: :manga),
  Item.create!(mal_id: 2, name: "Berserk", kind: :manga),
  Item.create!(mal_id: 3, name: "20th Century Boys", kind: :manga),
  Item.create!(mal_id: 4, name: "Yokohama Kaidashi Kikou", kind: :manga),
  Item.create!(mal_id: 7, name: "Hajime no Ippo", kind: :manga),
  Item.create!(mal_id: 8, name: "Full Moon wo Sagashite", kind: :manga),
  Item.create!(mal_id: 9, name: "Tsubasa: RESERVoir CHRoNiCLE", kind: :manga),
  Item.create!(mal_id: 10, name: "xxxHOLiC", kind: :manga),
  Item.create!(mal_id: 11, name: "Naruto", kind: :manga),
  Item.create!(mal_id: 12, name: "Bleach", kind: :manga),
  Item.create!(mal_id: 13, name: "One Piece", kind: :manga),
  Item.create!(mal_id: 1, name: "Cowboy Bebop", kind: :anime),
  Item.create!(mal_id: 5, name: "Cowboy Bebop: Tengoku no Tobira", kind: :anime),
  Item.create!(mal_id: 6, name: "Trigun", kind: :anime),
  Item.create!(mal_id: 7, name: "Witch Hunter Robin", kind: :anime),
  Item.create!(mal_id: 8, name: "Bouken Ou Beet", kind: :anime),
  Item.create!(mal_id: 15, name: "Eyeshield 21", kind: :anime),
  Item.create!(mal_id: 16, name: "Hachimitsu to Clover", kind: :anime),
  Item.create!(mal_id: 17, name: "Hungry Heart: Wild Striker", kind: :anime),
  Item.create!(mal_id: 18, name: "Initial D Fourth Stage", kind: :anime),
  Item.create!(mal_id: 19, name: "Monster", kind: :anime),
  Item.create!(mal_id: 20, name: "Naruto", kind: :anime),
  Item.create!(mal_id: 21, name: "One Piece", kind: :anime)
]

(2.years.ago(Date.today)..Date.today).each do |date|
  skip_date = [true, false].sample

  next if skip_date

  entries = rand(1..4)
  entries.times do
    Entry.create!(user: user, item: items.sample, timestamp: date.to_datetime, amount: rand(1..21))
  end
end

user.activities.generate_from_history
