require 'deebee/version'

require 'sinatra/base'
require 'sequel'

require 'cgi'

module Deebee
  class Error < StandardError; end

  class ConnectionError < Error
    def initialize(url)
      @url = url
    end

    def message
      "Invalid DATABASE_URL value: #{ENV['DATABASE_URL'].inspect}"
    end
  end

  class App < Sinatra::Base
    set :root, File.expand_path('../deebee', __FILE__)

    configure do
      begin
        set :db, Sequel.connect(ENV['DATABASE_URL'])
        set :tables, settings.db.tables.sort
      rescue Sequel::Error
        raise ConnectionError.new(ENV['DATABASE_URL'])
      end
    end

    before do
      @db = settings.db
      @tables = settings.tables
      redirect request.path_info.sub(/\/$/, '') if request.path_info =~ /.+\/$/
    end

    get '/' do
      redirect to('/tables')
    end

    get '/tables' do
      erb :index
    end

    get '/tables/:table' do
      table = params[:table].to_sym

      @table   = @db[table]
      @schema  = Hash[@db.schema(table)]

      if @schema.has_key? :id
        @records = @table.limit(500).order(:id).all
      else
        @records = @table.limit(500).all
      end

      erb :table
    end

    get '/tables/:table/page/:page' do
      table = params[:table].to_sym

      @table   = @db[table]
      @schema  = Hash[@db.schema(table)]

      offset = 500 * (params[:page].to_i) - 500

      if @schema.has_key? :id
        @records = @table.limit(500, offset).order(:id).all
      else
        @records = @table.limit(500, offset).all
      end

      erb :table
    end
  end
end
