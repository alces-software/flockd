module Flockd
  class Triggers
    class Trigger
      attr_accessor :type, :file

      def initialize(file, type)
        self.type = type
        self.file = file
      end

      def run
        if type == 'sh'
          output = IO.popen(['/bin/bash', file], 'r+') do |io|
            begin
              loop do
                line = io.readline.chomp
                Flockd.logger.info "> #{line}"
                case line
                when /^clusters$/
                  cluster_names = clusters.map{|c| c['name']}
                  Flockd.logger.info cluster_names.join(" ")
                  io.write cluster_names.join(" ") + "\n"
                when /^localcluster$/
                  Flockd.logger.info Flockd.config.name
                  io.write Flockd.config.name + "\n"
                when /^get (\S*) (\S*)/
                  cluster = $1
                  key = $2
                  if local?(cluster)
                    Flockd.logger.info "#{Flockd.values[key].inspect}"
                    io.write Flockd.values[key].to_s + "\n"
                  else
                    cluster_endpoint = endpoint_for(cluster)
                    if cluster_endpoint
                      value = Flockd::Query::Basic.new("value")
                                .retrieve(cluster_endpoint, {name: key})
                      Flockd.logger.info value.inspect
                      io.write value + "\n"
                    else
                      io.write "\n"
                    end
                  end
                when /^#/
                  # no-op
                  nil
                when '---'
                  break
                else
                  Flockd.logger.info ""
                  io.write "\n"
                end
              end
              io.read
            rescue EOFError
              '{}'
            end
          end
          out_vals = YAML.load(output)
          out_vals.each do |k,v|
            Flockd.logger.info "=> #{k}: #{v}"
            Flockd.values.set(k.to_s, v)
          end
        elsif type == 'yml'
          descriptor = YAML.load_file(file)
          # XXX - do some kind of clever stuff here, like communicate with other clusters etc.
          # i.e. this needs to support "replication" hooks
          Flockd.logger.info descriptor.inspect
        else
          nil
        end
      end

      private
      def local?(cluster_name)
        cluster_name == Flockd.config.name
      end

      def endpoint_for(cluster_name)
        cluster = clusters.find do |c|
          c['name'] == cluster_name
        end
        cluster && cluster['endpoint']
      end

      def clusters
        if Flockd.hub?
          Flockd::Reporter::Clusters.report
        else
          cluster_query = Flockd::Query::Basic.new('clusters')
          cluster_query.retrieve(Flockd.config.hub_endpoint_url)
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
        Dir[File.join(Flockd.config.trigger_dir,'*')].each do |f|
          base = File.basename(f)
          next unless base.include?('.')
          *base_parts, type = base.split('.')
          h[base_parts.join('.').to_sym] = Trigger.new(f, type)
        end
      end
    end
  end
end
