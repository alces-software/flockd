module Flockd
  class Reports
    def list
      reports
    end

    def get(report)
      if reports.key?(report)
        descriptor = reports[report]
        {}.tap do |h|
          descriptor['fields'].each do |f|
            name = f['name']
            h[name] =
              if name == :name
                Flockd.config.name
              else
                Flockd.values[name]
              end
          end
        end
      end
    end

    private
    def reports
      @reports ||= load
    end

    def load
      {}.tap do |h|
        Dir[File.join(Flockd.config.report_dir,'*.yml')].each do |f|
          h[File.basename(f,'.yml')] = YAML.load_file(f)
        end
      end
    end
  end
end
