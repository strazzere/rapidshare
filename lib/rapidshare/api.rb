# encoding: utf-8

module Rapidshare

  # Provides interface to RapidShare API.
  #
  # HTTPS requests are used by default, as recommended by RapidShare API
  # documentation. If you want to use HTTP, you have to write complete URI in the
  # API request, for example:
  #
  #   Rapidshare::API.get('https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=...')
  #
  class API
  
    attr_reader :cookie
  
    ERROR_PREFIX = "ERROR: " unless defined?(ERROR_PREFIX)
  
    # custom errors for Rapidshare::API class
    class Error < StandardError; end
    class Error::LoginFailed < StandardError; end
    class Error::InvalidRoutineCalled < StandardError; end
  
    # Request method uses this string to construct GET requests
    #
    URL = 'https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=%s&%s'
  
    # Connects to Rapidshare API (which basically means: uses login and password
    # to retrieve cookie for future service calls)
    #
    # Params:
    # * *login* - premium account login
    # * *password* - premium account password
    # * *cookie* - cookie can be provided instead of login and password
    #
    # * *proxy* - proxy to use for connecting to rapidshare
    #
    # Instead of params hash, you can pass only cookie as a string 
    def initialize(params)
      if !params[:proxy].nil? && !params[:proxy][:proxy_address].nil?
        @proxy = params[:proxy]
      else
        @proxy = {}
      end

      params = { :cookie => params } if params.is_a? String

      if params[:cookie]
        @cookie = params[:cookie]
        # throws LoginFailed exception if cookie is invalid
        get_account_details()
      else
        response = get_account_details(params.merge(:withcookie => 1))
        @cookie = response[:cookie]
      end
    end
  
    def self.debug(debug)
      debug_output debug ? $stderr : false
    end
  
    # TODO this class is getting long. keep general request-related and helper
    # method here and move specific method calls like :getaccountdetails to other
    # class (service)? 
    #
    # TODO enable users to define their own parsers and pass them as code blocks?
    # not really that practical, but it would be a cool piece of code :)
  
    # Calls specific RapidShare API service and returns result.
    #
    # Throws exception if error is received from RapidShare API.
    #
    # Params:
    # * *service_name* - name of the RapidShare service, for example +checkfiles+
    # * *params* - hash of service parameters and options (listed below)
    # * *parser* - option, determines how the response body will be parsed:
    #   * *none* - default value, returns response body as it is
    #   * *csv* - comma-separated values, for example: _getrapidtranslogs_.
    #     Returns array or arrays, one array per each line.
    #   * *hash* - lines with key and value separated by "=", for example:
    #     _getaccountdetails_. Returns hash.
    #
    def self.request(service_name, params = {}, proxy = {})
      params.symbolize_keys!
      
      parser = (params.delete(:parser) || :none).to_sym
      unless [:none, :csv, :hash].include?(parser)
        raise Rapidshare::API::Error.new("Invalid parser for request method: #{parser}")
      end
  
      response = self.get(URL % [service_name, params.to_query], proxy).body
      
      if response.start_with?(ERROR_PREFIX)
        case error = response.sub(ERROR_PREFIX, "").split('.').first
          when "Login failed"
            raise Rapidshare::API::Error::LoginFailed
          when "Invalid routine called"
            raise Rapidshare::API::Error::InvalidRoutineCalled.new(service_name)
          else
            raise Rapidshare::API::Error.new(error)
          end
      end
      
      self.parse_response(parser, response)
    end
  
    # Provides instance interface to class method +request+.
    #
    def request(service_name, params = {})
      self.class.request(service_name, params.merge(:cookie => @cookie), @proxy)
    end
  
    # Parses response from +request+ method (parser options are listed there)
    #
    def self.parse_response(parser, response)    
      case parser.to_sym
        when :none
          response
        when :csv
          # PS: we could use gem for csv parsing, but that's an overkill in this
          # case, IMHO
          response.to_s.strip.split(/\s*\n\s*/).map { |line| line.split(',') }
        when :hash
          self.text_to_hash(response)
      end
    
    end

    # Attempts to do Rapidshare service call. If it doesn't recognize the method
    # name, this gem assumes that user wants to make a Rapidshare service call.
    #
    # This method also handles aliases for service calls:
    # get_account_details -> getaccountdetails
    #    
    def method_missing(service_name, params = {})
      # remove user-friendly underscores from service namess
      service_name = service_name.to_s.gsub('_', '')
      
      if respond_to?(service_name)
        send(service_name, params)
      else
        request(service_name, params)
      end
    end  

    # Returns account details in hash.
    #
    def getaccountdetails(params = {})
      request :getaccountdetails, params.merge( :parser => :hash)
    end

    # Retrieves information about RapidShare files.
    #
    # *Input:* array of files
    #
    # Examples: +checkfiles(file1)+, +checkfiles(file1,file2)+ or +checkfiles([file1,file2])+
    #
    # *Output:* array of hashes, which contain information about files
    # * *:file_id* (string) - part of url
    #
    #   Example: https://rapidshare.com/files/829628035/HornyRhinos.jpg -> +829628035+
    # * *:file_name* (string) - part of url
    #
    #   Example: https://rapidshare.com/files/829628035/HornyRhinos.jpg -> +HornyRhinos.jpg+
    # * *:file_size* (integer) - in bytes. returns 0 if files does not exists
    # * *:file_status* - decoded file status: +:ok+ or +:error+
    # * *:short_host* - used to construct download url
    # * *:server_id* - used to construct download url
    # * *:md5* 
    #
    def checkfiles(*urls)
      raise Rapidshare::API::Error if urls.empty?
      
      files, filenames = urls.flatten.map { |url| fileid_and_filename(url) }.transpose
  
      response = request(:checkfiles, :files => files.join(","), :filenames => filenames.join(","))
      
      response.strip.split(/\s*\n\s*/).map do |r|
        data = r.split(",")
        {
          :file_id => data[0],
          :file_name => data[1],
          :file_size => data[2],
          :server_id => data[3],
          :file_status => self.class.decode_file_status(data[4].to_i),
          :short_host => data[5],
          :md5 => data[6]
        }
      end
    end
  
    # Downloads file.
    #
    # Options:
    # * *filename* (optional) - specifies filename under which the file will be
    #   saved. Default: filename parsed from Rapidshare link.
    # * *downloads_dir* (optional) - specifies directory into which downloaded files
    #   will be saved. Default: current directory.
    #
    def download(file, options= {})
      Rapidshare::Download.new(file, self, options, @proxy).perform
    end
  
    # helper methods
  
    # Provides interface for GET requests
    # 
    def self.get(url, proxy = {})
      url = URI.parse(url)

      http = Net::HTTP.new(url.host, url.port, proxy[:proxy_address], proxy[:proxy_port], proxy[:proxy_login], proxy[:proxy_password])
      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.get URI::escape(url.request_uri)
    end
  
    # Convert file status code (returned by checkfiles method) to +:ok+ or +:error+ symbol.
    #
    def self.decode_file_status(status_code)
      # TODO in checkfiles, return both file_status as is and decoded file status
      # or just boolean value if file is OK and can be downloaded
  
      case status_code
        when 0 then :error # File not found
        when 1 then :ok # File OK
        when 3 then :error # Server down
        when 4 then :error # File marked as illegal
        else :error # uknown status, this shouldn't happen
      end
    end
  
    # Extracts file id and file name from Rapidshare url. Returns both in array.
    #
    # Example:
    #   https://rapidshare.com/files/829628035/HornyRhinos.jpg -> [ '829628035', 'HornyRhinos.jpg' ] 
    #
    def fileid_and_filename(url)
      url.split('/').slice(-2,2) || ['', '']
    end
  
    # Converts rapidshare response (which is just a text in specific format) to hash.
    #
    # Example:
    #   "key1=value1\nkey1=value2" -> { :key1 => 'value1', :key2 => 'value2' }
    #
    def self.text_to_hash(response)
      Hash[ response.strip.split(/\s*\n\s*/).map { |param| param.split('=') } ].symbolize_keys
    end
  
  end

end
