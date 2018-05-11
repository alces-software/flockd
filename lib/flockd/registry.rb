module Flockd
  class Registry
    DEFAULTS = {
      endpoints: []
    }

    def record(endpoint)
      unless endpoints.include?(endpoint)
        if reachable?(endpoint)
          endpoints << endpoint
          save
          :ok
        else
          :unreachable
        end
      else
        :exists
      end
    end

    def endpoints
      data[:endpoints]
    end

    private
    def data
      @data ||= load
    end

    def load
      if File.exists?(Flockd.config.registry)
        YAML.load_file(Flockd.config.registry)
      else
        DEFAULTS.dup
      end
    end

    def save
      File.write(Flockd.config.registry, data.to_yaml)
    end

    def reachable?(endpoint)
      name_query = Flockd::Query::Basic.new('name')
      begin
        name_query.retrieve!(endpoint)
        true
      rescue Faraday::ConnectionFailed
        false
      end
    end
  end
end
