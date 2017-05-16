# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

track = Track.create!(
  title: 'LUVORATORRRRRY!',
  tags: 'niconico,VOCALOID,ボカラボ',
  artist: 'GUMI&RIN',
  album: 'ニコニコ',
  duration: 207,
  status: 'OK',
  szhash: '5a9b41a9964b3f49a19b561b04fcb16e981cad3e',
  niconico: 'sm22942867',
  uploader: 'utaitedb.net'
)
track.playlists.create!(
  playedtime: Time.now.utc
)
track.images.create!(
  url: '//i.imgur.com/0eSuyIv.jpg',
  source: 'http://www.pixiv.net/member_illust.php?mode=medium&illust_id=42917318',
  illustrator: '楠チェリー＠プロフ修正しました',
)
Member.create!(
  username: 'admin@phate.io',
  password: '90b9aa7e25f80cf4f64e990b78a9fc5ebd6cecad',
  identity: '352117141dcf7c3708301fa8ff811f41',
  nickname: 'Admin',
  access: 10
)
