module RubyHome
  module HTTP
    class ApplicationController < Sinatra::Base
      disable :protection

      if ENV['DEBUG']
        enable :logging
        set :logger, Logger.new(STDOUT)
      end

      protected

      def unpack_request
        @_unpack_request ||= _unpack_request
      end

      def json_body
        @_json_body ||= _unpack_json
      end

      def accessory_info
        AccessoryInfo.instance
      end

      def identifier_cache
        IdentifierCache
      end

      def cache
        RequestStore.store[Application.socket] ||= {}
      end

      def clear_cache
        RequestStore.store[Application.socket] = {}
      end

      def tlv(object)
        HAP::TLV.encode(object)
      end

      def logger
        if settings.respond_to?(:logger)
          settings.logger
        else
          request.logger
        end
      end

      private

      def rewind_request
        if request.body.size > 0
          request.body.rewind
        end
      end

      def request_body
        rewind_request
        request.body.read
      end

      def _unpack_request
        HAP::TLV.read(request_body).tap do |request_tlv|
          logger.debug request_tlv
        end
      end

      def _unpack_json
        JSON.parse(request_body).tap do |request_json|
          logger.debug request_json
        end
      end
    end
  end
end
