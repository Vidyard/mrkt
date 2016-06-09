require 'mrkt/version'
require 'mrkt/errors'

require 'mrkt/concerns/connection'
require 'mrkt/concerns/authentication'
require 'mrkt/concerns/crud_helpers'
require 'mrkt/concerns/crud_campaigns'
require 'mrkt/concerns/crud_leads'
require 'mrkt/concerns/crud_lists'
require 'mrkt/concerns/import_leads'
require 'mrkt/concerns/crud_custom_objects'
require 'mrkt/concerns/crud_programs'

module Mrkt
  class Client
    include Connection
    include Authentication
    include CrudHelpers
    include CrudCampaigns
    include CrudLeads
    include CrudLists
    include ImportLeads
    include CrudCustomObjects
    include CrudPrograms

    attr_accessor :debug

    def initialize(options = {})
      @host = options.fetch(:host)

      @client_id = options.fetch(:client_id)
      @client_secret = options.fetch(:client_secret)

      @retry_authentication = options[:retry_authentication].nil? ? false : options[:retry_authentication]
      @retry_authentication_count = options[:retry_authentication_count].nil? ? 3 : options[:retry_authentication_count].to_i
      @retry_authentication_wait_seconds = options[:retry_authentication_wait_seconds].nil? ? 0 : options[:retry_authentication_wait_seconds].to_i

      @debug = options[:debug]

      @logger = options[:logger]
      @log_options = options[:log_options]

      @options = options
    end

    %i(get post delete).each do |http_method|
      define_method(http_method) do |path, payload = {}, &block|
        authenticate!

        resp = connection.send(http_method, path, payload) do |req|
          add_authorization(req)
          block.call(req) unless block.nil?
        end

        resp.body
      end
    end
  end
end
