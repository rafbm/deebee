require 'deebee/version'

require 'sinatra/base'
require 'sequel'

require 'cgi'

module Deebee
  class Error < StandardError; end
  class ConnectionError < Error
    def message; 'Invalid DATABASE_URL or database.yml'; end
  end

  class App < Sinatra::Base
    set :root, File.expand_path('../deebee', __FILE__)

    before do
      @@db ||= nil

      unless @@db
        begin
          if ENV['DATABASE_URL']
            @@db = Sequel.connect(ENV['DATABASE_URL'])
          else
            config = Rails.configuration.database_configuration[Rails.env]

            # TODO Test other adapters
            config['adapter'] = 'postgres' if config['adapter'] =~ /postgres/

            @@db = Sequel.connect(
              adapter: config['adapter'],
              encoding: config['encoding'],
              database: config['database'],
              host: config['host'],
              port: config['port'],
              password: config['password'],
              user: config['username'],
              max_connections: config['pool'],
            )
          end
          @@tables = @@db.tables.sort
        rescue Sequel::Error, NameError
          raise ConnectionError
        end
      end

      @db = @@db
      @tables = @@tables
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
