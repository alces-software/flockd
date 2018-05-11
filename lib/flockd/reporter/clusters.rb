require 'flockd/query/basic'

module Flockd
  module Reporter
    module Clusters
      class << self
        def report(params = nil)
          name_query = Flockd::Query::Basic.new('name')
          Flockd.registry.endpoints.map do |e|
            {
              'name' => name_query.retrieve(e),
              'endpoint' => e
            }
          end
        end
      end
    end
  end
end
