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
  end
end
