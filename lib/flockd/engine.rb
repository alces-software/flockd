require 'flockd/reporter'
require 'flockd/reports'

module Flockd
  module Engine
    REPORTERS = {
      clusters: Reporter::Clusters,
      name: Reporter::Name,
      value: Reporter::Value,
    }

    class << self
      def valid_credentials?(username, password)
        if username == ''
          valid_superuser?(password)
        else
          password == Flockd.values["auth.#{username}"]
        end
      end

      def valid_superuser?(password)
        password == Flockd.config.password
      end

      def record(endpoint)
        Flockd.registry.record(endpoint)
      end

      def available?(type)
        REPORTERS.key?(type)
      end

      def query(type, params)
        {
          type: type,
          report: REPORTERS[type].report(params) || '-'
        }
      end

      def reports
        @reports ||= Reports.new
      end
    end
  end
end
