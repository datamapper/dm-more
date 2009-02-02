require 'net/http'

module DataMapperRest    
  # Stolen from ActiveResource
  class Connection
    attr_accessor :uri
    
    def initialize(uri)
      @uri = uri
    end
    
    def run_verb(verb, data = nil)
      request do |http|
        mod = Net::HTTP::module_eval(Inflection.camelize(verb))
        request = mod.new(@uri, 'Content-Type' => 'application/xml')
        request.basic_auth(@uri[:login], @uri[:password]) unless @uri[:login].blank?
        result = http.request(request, data)
        
        handle_response(result)
      end
    end
    
    # this is used to run the http verbs like http_post, http_put, http_delete etc.
    def method_missing(method, *args)
      @uri.path = "/#{args[0]}" # Should be the form of /resources
      if verb = method.to_s.match(/^http_(\w*)$/)
        run_verb(verb.to_s.split("_").last, @uri + args[0], args[1])
      end
    end

    def request(&block)
      res = nil
      Net::HTTP.start(@uri[:host], @uri[:port].to_i) do |http|
        res = yield(http)
      end
      res
    end
    
    # Handles response and error codes from remote service.
    def self.handle_response(response)
      case response.code.to_i
        when 301,302
          raise(Redirection.new(response))
        when 200...400
          response
        when 400
          raise(BadRequest.new(response))
        when 401
          raise(UnauthorizedAccess.new(response))
        when 403
          raise(ForbiddenAccess.new(response))
        when 404
          raise(ResourceNotFound.new(response))
        when 405
          raise(MethodNotAllowed.new(response))
        when 409
          raise(ResourceConflict.new(response))
        when 422
          raise(ResourceInvalid.new(response))
        when 401...500
          raise(ClientError.new(response))
        when 500...600
          raise(ServerError.new(response))
        else
          raise(ConnectionError.new(response, "Unknown response code: #{response.code}"))
      end
    end
  end
end