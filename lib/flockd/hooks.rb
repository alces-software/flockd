module Flockd
  class Hooks
    class Hook
      attr_accessor :type, :file

      def initialize(file, type)
        self.type = type
        self.file = file
      end

      def run(key, old, val)
        if type == 'sh'
          IO.popen(['/bin/bash', file, key, old, val])
        elsif type == 'yml'
          descriptor = YAML.load_file(file)
          # XXX - do some kind of clever stuff here, like communicate with other clusters etc.
          # i.e. this needs to support "replication" hooks
          puts descriptor.inspect, key, old, val
        else
          nil
        end
      end
    end

    def get(key)
      while key != '' do
        break if data.key?(key.to_sym)
        key = key.split('.').tap{|a| a.pop}.join('.')
      end
      data[key.to_sym]
    end

    private
    def data
      @data ||= load
    end

    def load
      {}.tap do |h|
        Dir[File.join(Flockd.config.hook_dir,'*')].each do |f|
          base = File.basename(f)
          next unless base.include?('.')
          *base_parts, type = base.split('.')
          h[base_parts.join('.').to_sym] = Hook.new(f, type)
          puts h.inspect
        end
      end
    end
  end
end
