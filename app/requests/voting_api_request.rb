class VotingApiRequest

  def initialize(uri)
    @uri = uri
    @request = nil
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

    http
  end

  def log_error(response)
    Rails.logger.error "ApiRequest Error: #{response.code}, #{response.body}" unless response.is_a?(Net::HTTPSuccess)
  end

  def set_headers
    @request['Authorization'] = "Bearer #{Vaalit::VotingApi::JWT_APIKEY}"
  end
end
