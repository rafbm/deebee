require 'bundler/setup'
Bundler.require

# Database connection
$db = Sequel.connect(ENV['DATABASE_URL'])
$tables = $db.tables

# Logging
require 'logger'
$db.loggers << Logger.new($stdout)
$db.sql_log_level = :debug

# HTTP authentication
use Rack::Auth::Basic, 'Deebee' do |username, password|
  username == ENV['HTTP_USERNAME'] && password == ENV['HTTP_PASSWORD']
end if ENV['HTTP_USERNAME'] && ENV['HTTP_PASSWORD']

# Wep app
before do
  redirect request.path.sub(/\/$/, '') if request.path =~ /.+\/$/
end

get '/' do
  redirect '/tables'
end

get '/tables' do
  erb :index
end

get '/tables/:table' do
  table = params[:table].to_sym

  @table   = $db[table]
  @schema  = Hash[$db.schema(table)]

  if @schema.has_key? :id
    @records = @table.limit(500).order(:id).all
  else
    @records = @table.limit(500).all
  end

  erb :table
end

run Sinatra::Application
