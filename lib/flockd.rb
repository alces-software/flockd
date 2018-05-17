require 'flockd/config'
require 'flockd/hooks'
require 'flockd/triggers'
require 'flockd/registry'
require 'flockd/values'

module Flockd
  class << self
    def hub?
      config.hub == true
    end

    def config
      @config ||= Config.new
    end

    def registry
      @registry ||= Registry.new
    end

    def values
      @values ||= Values.new
    end

    def hooks
      @hooks ||= Hooks.new
    end

    def triggers
      @triggers ||= Triggers.new
    end

    def logger
      @logger ||= begin
                    log_file = File.open(config.log_file, 'a')
                    log_file.sync = true
                    Logger.new GrapeLogging::MultiIO.new(STDOUT, log_file)
                  end
    end
  end
end
