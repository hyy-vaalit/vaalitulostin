class ImportVotesByVoterStartYearJob
  def perform
    Rails.logger.info "Fetch votes by voter start year from voting-api"

    uri = URI(Vaalit::VotingApi::BASE_URL + "/api/stats/votes_by_voter_start_year")
    response = VotingApiRequest.new(uri).get

    if !response.is_a?(Net::HTTPSuccess)
      if response.code.to_i == 401
        Rails.logger.error 'Vote fetching failed due to HTTP 401 unauthorized. Ignoring retry.'
        return
      else
        Rails.logger.error "Something went wrong while talking to voting-api, status: #{response.code}"
        raise "Error: Voting API request failed: " + response.body
      end
    end

    Rails.logger.info "Create Job to publish votes by voter_start_year"
    Delayed::Job.enqueue(PublishVotesByVoterStartYearJob.new(response.body))
  end
end
