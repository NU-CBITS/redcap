require 'hashie'
require 'json'
require 'rest-client'
require 'logger'
require 'dotenv'
require 'memoist'
require 'redcap/version'
require 'redcap/configuration'
require 'redcap/record'

Dotenv.load

module Redcap
  attr_reader :configuration

  class << self
    def new(options = {})
      if options.empty? && ENV
        options[:host] = ENV['REDCAP_HOST']
        options[:token] = ENV['REDCAP_TOKEN']
      end
      self.configure = options
      Redcap::Client.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure=(options)
      if options.nil?
        # :nocov:
        @configuration = nil
        # :nocov:
      else
        @configuration = Configuration.new(options)
      end
    end

    def configure
      yield configuration
      configuration
    end
  end

  class Client
    extend Memoist

    attr_reader :logger
    attr_writer :log

    def initialize
      @logger = Logger.new STDOUT
    end

    def configuration
      Redcap.configuration
    end

    def log?
      @log ||= false
    end

    # :nocov:
    def log message
      return unless @log
      @logger.debug message
    end
    # :nocov:

    # :nocov:
    def project
      payload = build_payload content: :project
      post payload
    end
    # :nocov:

    # :nocov:
    def max_id
      records(fields: %w(record_id)).map(&:values).flatten.map(&:to_i).max.to_i
    end
    # :nocov:

    # :nocov:
    def fields
      metadata.map { |m| m['field_name'].to_sym }
    end
    # :nocov:

    # :nocov:
    def metadata
      payload = {
        token: configuration.token,
        format: configuration.format,
        content: :metadata,
        fields: []
      }
      post payload
    end
    # :nocov:

    # :nocov:
    def records records: [], fields: [], filter: nil
      # add :record_id if not included
      fields |= [:record_id] if fields.any?
      payload = build_payload content: :record, records: records, fields: fields, filter: filter
      post payload
    end
    # :nocov:

    # :nocov:
    def update data=[]
      payload = {
        token: configuration.token,
        format: configuration.format,
        content: :record,
        overwriteBehavior: :normal,
        type: :flat,
        returnContent: :count,
        data: data.to_json
      }
      log flush_cache if ENV['REDCAP_CACHE']=='ON'
      result = post payload
      result['count'] == 1
    end
    # :nocov:

    # :nocov:
    def create data=[]
      payload = {
        token: configuration.token,
        format: configuration.format,
        content: :record,
        overwriteBehavior: :normal,
        type: :flat,
        returnContent: :ids,
        data: data.to_json
      }
      log flush_cache if ENV['REDCAP_CACHE']=='ON'
      post payload
    end
    # :nocov:

    # :nocov:
    def survey_link record_id: nil, instrument: nil
      payload = build_record_payload content: :surveyLink, record_id: record_id, instrument: instrument
      post_without_parsing payload
    end
    # :nocov:

    private

    def build_payload content: nil, records: [], fields: [], filter: nil
      payload = {
        token: configuration.token,
        format: configuration.format,
        content: content
      }
      records.each_with_index do |record, index|
        payload["records[#{index}]"] = record
      end if records
      fields.each_with_index do |field, index|
        payload["fields[#{index}]"] = field
      end if fields
      payload[:filterLogic] = filter if filter
      payload
    end

    # :nocov:
    def build_record_payload content: nil, record_id: nil, instrument: nil
      {
        token: configuration.token,
        format: configuration.format,
        content: content,
        instrument: instrument,
        record: record_id
      }
    end
    # :nocov:

    # :nocov:
    def post payload = {}
      log "Redcap POST to #{configuration.host} with #{payload}"
      response = RestClient.post configuration.host, payload
      response = JSON.parse(response)
      log 'Response:'
      log response
      response
    end
    memoize(:post) if ENV['REDCAP_CACHE']=='ON'
    # :nocov:

    # :nocov:
    def post_without_parsing payload = {}
      log "Redcap POST to #{configuration.host} with #{payload}"
      response = RestClient.post configuration.host, payload
      log 'Response:'
      log response
      response
    end
    # :nocov:

  end

end
