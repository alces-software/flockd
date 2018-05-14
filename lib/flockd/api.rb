require 'grape'
require 'flockd/engine'

module Flockd
  class API < Grape::API
    format :json

    head '/ping' do
      status 204
      ''
    end

    get '/ping' do
      status 204
      ''
    end

    desc 'Query a flock member.'
    namespace :query do
      route_param :type do
        get do
          type = params[:type].to_sym
          if Engine.available?(type)
            status 200
            Engine.query(type, params)
          else
            status 404
            {
              type: type,
              error: "not found"
            }
          end
        end
      end
    end

    desc 'Set a flock value.'
    namespace :set do
      post do
        username, password = ::Base64.decode64(request.headers['Authorization'].split(' ', 2).last || '').split(':')
        key = params[:key]
        # if superuser allow all sets
        # if not superuser, allow sets to `user.<username>`
        allowed =
          if Engine.valid_superuser?(password)
            true
          elsif key.start_with?('user.')
            user = key.split('.')[1]
            (username == user || username == 'hub') && Engine.valid_credentials?(username, password)
          else
            false
          end
        if allowed
          Flockd.values.set(key, params[:value], params[:mode])
          status 204
        else
          status 401
        end
        ''
      end
    end

    desc 'Trigger a flock trigger.'
    namespace :trigger do
      post do
        op = Flockd.triggers.get(params[:op])
        if op.nil?
          status 404
        else
          op.run
          status 204
        end
        ''
      end
    end
    
    # Hub-mode:

    desc 'Register to the flock.'
    namespace :register do
      http_basic do |username, password|
        Engine.valid_superuser?(password)
      end
      params do
        requires :endpoint
      end
      post do
        result = Engine.record(params[:endpoint])
        if result == :ok
          status 204
          ''
        else
          status 403
          {
            error: result
          }
        end
      end
    end

    desc 'Get list of available reports.'
    namespace :reports do
      get do
        status 200
        Engine.reports.list
      end

      route_param :report do
        get do
          if report = Engine.reports.get(params[:report])
            status 200
            report
          else
            status 404
          end
        end
      end
    end
  end
end
