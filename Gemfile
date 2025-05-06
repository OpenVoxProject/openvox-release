source 'https://rubygems.org'

def location_for(place)
  if place =~ /^((?:git[:@]|https:)[^#]*)#(.*)/
    [{ git: $1, branch: $2, require: false }]
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { path: File.expand_path($1), require: false }]
  else
    [place, { require: false }]
  end
end

gem 'rake'
gem 'fpm'
gem 'ostruct'
gem 'logger'
