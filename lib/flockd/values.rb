module Flockd
  class Values
    RESTRICTED_NAMESPACES = ['auth.']

    def restricted?(k)
      RESTRICTED_NAMESPACES.any? do |ns|
        k.start_with?(ns)
      end
    end

    def [](k)
      data[k.to_sym]
    end

    def set(key, val, mode = 'set')
      old = data[key.to_sym]
      data[key.to_sym] = val
      if old != val
        hook = Flockd.hooks.get(key)
        hook.run(key, old, val, mode) unless hook.nil?
      end
    ensure
      save
    end

    private
    def data
      @data ||= load
    end

    def load
      if File.exists?(Flockd.config.values)
        YAML.load_file(Flockd.config.values)
      else
        {}
      end
    end

    def save
      File.write(Flockd.config.values, data.to_yaml)
    end
  end
end
