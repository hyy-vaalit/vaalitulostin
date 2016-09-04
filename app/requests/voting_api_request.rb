class VotingApiRequest

  def initialize(uri)
    @uri = uri
    @request = nil
  end

  def get
    response = Net::HTTP.start(@uri.host, @uri.port) do |http|
      @request = Net::HTTP::Get.new @uri
      set_headers

      http.request @request
    end

    log_error response
    response
  end

  def post(params)
    response = Net::HTTP.start(@uri.host, @uri.port) do |http|
      @request = Net::HTTP::Post.new @uri
      set_headers
      @request.set_form_data HashConverter.encode(params)

      http.request @request
    end

    log_error response
    response
  end

  private

  def log_error(response)
    Rails.logger.error "ApiRequest Error: #{response.code}, #{response.body}" unless response.is_a?(Net::HTTPSuccess)
  end

  def set_headers
    @request['Authorization'] = "Bearer #{Vaalit::VotingApi::JWT_APIKEY}"
  end
end
