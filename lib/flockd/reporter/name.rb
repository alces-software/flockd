module Flockd
  module Reporter
    module Name
      class << self
        def report(params)
          Flockd.config.name
        end
      end
    end
  end
end
