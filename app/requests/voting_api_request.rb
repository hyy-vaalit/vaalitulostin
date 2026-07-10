class VotingApiRequest
  def initialize(uri)
    @uri = uri
    @request = nil
  end

  # As #get, but raises unless the response is a success. Use this from
  # jobs so a failing Voting API call can never be mistaken for data.
  def get!
    response = get
    return response if response.is_a?(Net::HTTPSuccess)

    raise "Voting API request to #{@uri.path} failed: HTTP #{response.code}"
  end

  def get
    http = init_http(@uri)

    response = http.start do
      @request = Net::HTTP::Get.new @uri
      set_headers

      http.request @request
    end

    log_error response
    response
  end

  def post(params)
    http = init_http(@uri)

    response = http.start do
      @request = Net::HTTP::Post.new @uri
      set_headers
      @request.set_form_data HashConverter.encode(params)

      http.request @request
    end

    log_error response
    response
  end

  private

  def init_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"
    # Net::HTTP defaults to 60s timeouts which can block the single
    # delayed_job worker for minutes on election night.
    http.open_timeout = 5
    http.read_timeout = 30

    http
  end

  def log_error(response)
    Rails.logger.error "ApiRequest Error: #{response.code}, #{response.body}" unless response.is_a?(Net::HTTPSuccess)
  end

  def set_headers
    @request['Authorization'] = "Bearer #{Vaalit::VotingApi::JWT_APIKEY}"
  end
end
