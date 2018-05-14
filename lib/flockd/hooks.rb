module Flockd
  class Hooks
    class Hook
      attr_accessor :type, :file

      def initialize(file, type)
        self.type = type
        self.file = file
      end

      def run(key, old, val, mode)
        if type == 'sh'
          mode = (Flockd.hub? ? 'hub' : mode)
          IO.popen(['/bin/bash', file, key, old, val, mode || 'set'], 'r+') do |io|
            begin
              loop do
                line = io.readline.chomp
                puts "> #{line}"
                case line
                when /^replicate (\S*)$/
                  if Flockd.hub?
                    # replicate to all clusters
                    Flockd.registry.endpoints.each do |endpoint|
                      replicate(Flockd.config.hub_endpoint_url, $1)
                    end
                  else
                    # replicate to hub
                    replicate(Flockd.config.hub_endpoint_url, $1)
                  end
                when /^#/
                  # no-op
                  nil
                else
                  puts ""
                  io.write "\n"
                end
              end
              io.read
            rescue EOFError
              nil
            end
          end
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

    def replicate(endpoint, key)
      val = Flockd.values.get(key)
      connection = Faraday.new(endpoint) do |conn|
        conn.response :json, :content_type => /\bjson$/
        conn.basic_auth('hub',Flockd.config.values['auth.hub'])
        conn.adapter Faraday.default_adapter
      end
      resp = connection(auth).post('set') do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = {key: k, value: v, mode: 'replicate'}.to_json
      end
      resp.status == 204
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
