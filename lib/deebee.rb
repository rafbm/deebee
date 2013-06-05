# encoding: utf-8
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

    helpers do
      def next_records_link
        return link_to('Next »') unless @records.size >= @limit

        page_url = records_page_url(1)
        link_to 'Next »', page_url, true
      end

      def prev_records_link
        return link_to('« Prev') unless @page > 1

        page_url = records_page_url(-1)
        link_to '« Prev', page_url, true
      end

      def records_page_url(increment)
        "/tables/#{params[:table]}/page/#{@page + increment}"
      end

      def link_to(label, _url=nil, with_query_string=false)
        if _url
          _url << "?#{request.query_string}" if with_query_string && !request.query_string.empty?
          %(<a href="#{url(_url)}">#{label}</a>).html_safe
        else
          %(<a>#{label}</a>).html_safe
        end
      end
    end

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
      set_table
      erb :table
    end

    get '/tables/:table/page/:page' do
      set_table
      erb :table
    end

  private
    def set_table
      table = params[:table].to_sym

      @table   = @db[table]
      @schema  = Hash[@db.schema(table)]

      @page = (params[:page] || 1).to_i
      @limit = (params[:limit] || 500).to_i
      offset = @limit * @page - @limit

      if @schema.has_key? :id
        @records = @table.limit(@limit, offset).order(:id).all
      else
        @records = @table.limit(@limit, offset).all
      end
    end
  end
end
