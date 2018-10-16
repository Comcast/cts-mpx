module Cts
  module Mpx
    # Container style module for the collection of services available.
    module Services
      module_function

      # Addressable method, indexed by service title
      # @param [String] key service title to look up the service object
      # @raise [ArgumentError] if the key is not a service name
      # @raise [ArgumentError] if the key is not a string
      # @return [Service[]] if no key, return the entire array of services
      # @return [Service] a service
      def [](key = nil)
        return @services unless key
        raise 'key must be a string' unless key.is_a? String

        service = @services.find { |e| e.name == key }
        raise "#{key} must be a service name." unless service

        service
      end

      # return a service from the supplied url
      # @param [String] url url to parse
      # @return [Hash] including service and endpoint as string.
      def from_url(url)
        type = 'data' if url.include? 'data'
        uri = URI.parse url

        service = Services[].find { |s| uri.host.include?(s.uri_hint) if s.uri_hint && s.type == type }
        return nil unless service

        {
          service:  service.name,
          endpoint: /data\/([a-zA-Z]*)\//.match(url)[1]
        }
      end

      # Load references and services from disk.
      def initialize
        load_references
        load_services
      end

      # Load the specified reference file into the container
      # @param [<Type>] file file to load
      # @param [<Type>] type type of service the file contains
      # @return [Void]
      def load_reference_file(file: nil, type: nil)
        raise ArgumentError, 'type must be supplied' unless type
        raise ArgumentError, 'file must be supplied' unless file
        @raw_reference.store(type, Driver.load_json_file(file))
        true
      end

      # Load all available reference files into memory
      # @return [Void]
      def load_references
        @raw_reference = {}
        Services.types.each do |type|
          gemdir = if Gem::Specification.find_all.map(&:name).include? 'cts-mpx'
                     Gem::Specification.find_by_name('cts-mpx').gem_dir
                   else
                     # :nocov:
                     Dir.pwd
                     # :nocov:
                   end

          Services.load_reference_file(file: "#{gemdir}/config/#{type}_services.json", type: type.to_s)
        end
      end

      # Convert the raw reference into a service and add it to the stack of available serrvices
      # @return [Void]
      def load_services
        @services = []
        raw_reference.each do |type, services|
          services.each do |name, data|
            s = Driver::Service.new
            s.name = name
            s.uri_hint = data['uri_hint']
            s.path = data['path']
            s.form = data['form']
            s.schema = data['schema']
            s.search_schema = data['search_schema']
            s.read_only = data['read_only'] ? true : false
            s.endpoints = data['endpoints']
            s.type = type
            s.instance_variable_set :@url, data['url'] if data['url']
            @services.push s
          end
        end
      end

      # Raw copy of the reference files
      # @return [Hash] key is name, value is the data
      def raw_reference
        @raw_reference
      end

      # Single reference from the raw collection.
      # @param [String] key service title
      # @return [Hash] values of the reference
      def reference(key = nil)
        return @raw_reference unless key
        raise 'key must be a string' unless key.is_a? String
        raise "#{key} is not in the reference library." unless @raw_reference.include? key
        @raw_reference[key]
      end

      # list of possible types of services
      # @return [Symbol[]] List of all types
      def types
        %i[web data ingest]
      end
    end
  end
end
