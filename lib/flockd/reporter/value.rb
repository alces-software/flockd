module Flockd
  module Reporter
    module Value
      class << self
        def report(params)
          if !Flockd.values.restricted?(params['name'])
            Flockd.values[params['name']]
          end
        end
      end
    end
  end
end
