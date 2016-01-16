def create_twitter_url(id, screen_name)
  return 'https://twitter.com/' + screen_name + '/status/' + id.to_s
end