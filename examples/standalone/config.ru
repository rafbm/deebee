ENV['DATABASE_URL'] ||= 'YOUR_DATABASE_URL'

require 'deebee'

# HTTP authentication
use Rack::Auth::Basic, 'Deebee' do |username, password|
  username == ENV['HTTP_USERNAME'] && password == ENV['HTTP_PASSWORD']
end if ENV['HTTP_USERNAME'] && ENV['HTTP_PASSWORD']

run Deebee::App
