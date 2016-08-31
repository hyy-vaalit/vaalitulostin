class VotingApiRequest

  def initialize(uri)
    @uri = uri
    @req = Net::HTTP::Get.new(@uri)
    @req['Authorization'] = "Bearer #{Vaalit::VotingApi::JWT_APIKEY}"
  end

  def get
    res = Net::HTTP.start(@uri.hostname, @uri.port) do |http|
      http.request @req
    end

    res
  end
end
