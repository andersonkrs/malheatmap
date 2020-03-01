user = User.create(
  username: "andersonkrs",
  avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg?t=1579970400"
)

Entry.create([
  {
    user: user,
    timestamp: Time.zone.local(2019, 12, 25, 12, 15, 43),
    amount: 2,
    item_id: 38_992,
    item_name: "Rikei ga Koi ni Ochita no de Shoumei shitemita.",
    item_kind: Entry.item_kinds[:anime]
  },
  {
    user: user,
    timestamp: Time.zone.local(2019, 12, 25, 18, 10, 15),
    amount: 1,
    item_id: 38_992,
    item_name: "Rikei ga Koi ni Ochita no de Shoumei shitemita.",
    item_kind: Entry.item_kinds[:anime]
  }
])
