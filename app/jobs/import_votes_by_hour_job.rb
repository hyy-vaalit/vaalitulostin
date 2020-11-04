class ImportVotesByHourJob
  def perform
    Rails.logger.info "Fetch votes by hour from voting-api"

    uri = URI(Vaalit::VotingApi::BASE_URL + "/api/stats/votes_by_hour")
    response = VotingApiRequest.new(uri).get

    if !response.is_a?(Net::HTTPSuccess)
      if response.code.to_i == 401
        Rails.logger.error 'Voting-api request failed due to HTTP 401 unauthorized. Ignoring retry.'
        return
      else
        Rails.logger.error "Something went wrong while talking to voting-api, status: #{response.code}"
        raise "Error: Voting API request failed: " + response.body
      end
    end

    Rails.logger.info "Create Job to publish votes by hour"
    Delayed::Job.enqueue(PublishVotesByHourJob.new(response.body))
  end
end
