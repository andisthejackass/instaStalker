require "instagram"

CALLBACK_URL = "http://localhost:4567/oauth/callback"

Instagram.configure do |conf|
  conf.client_id = ""
  conf.client_secret = ""
end

puts Instagram.user_search("andisthejackass")
