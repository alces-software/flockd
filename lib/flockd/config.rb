require 'yaml'

module Flockd
  class Config
    FLOCKD_ROOT = ENV['FLOCK_ROOT'] || '/opt/flockd'
    CONFIG_FILE = ENV['FLOCK_CONFIG'] || "#{FLOCKD_ROOT}/etc/config.yml"
    DEFAULTS = {
      registry: ENV['FLOCK_REGISTRY'] || "#{FLOCKD_ROOT}/etc/registry.yml",
      values: "#{FLOCKD_ROOT}/etc/values.yml",
      report_dir: "#{FLOCKD_ROOT}/etc/reports",
      hook_dir: "#{FLOCKD_ROOT}/etc/hooks",
      trigger_dir: "#{FLOCKD_ROOT}/etc/triggers",
      password: ENV['FLOCK_PASSWORD'],
      name: 'unnamed',
      hub: false,
      hub_endpoint_url: 'http://127.0.0.1:9292',
      log_file: "/tmp/flockd.log",
    }

    def method_missing(s, *a, &b)
      if data.key?(s)
        data[s]
      else
        super
      end
    end

    def respond_to_missing(s)
      data.key?(s)
      super
    end

    private
    def data
      @data ||= load
    end

    def load
      DEFAULTS.dup.tap do |config|
        if File.exists?(CONFIG_FILE)
          config.merge!(YAML.load_file(CONFIG_FILE))
        end
      end
    end
  end
end
