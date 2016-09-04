class ImportVotesJob

  def initialize(voting_area)
    @voting_area = voting_area
  end

  def perform
    Rails.logger.info "Get election summary from voting-api"
    summary_response = VotingApiRequest
                       .new(Vaalit::VotingApi::SUMMARY_URI)
                       .get

    GlobalConfiguration.update_summary!(JSON.parse(summary_response.body))

    Rails.logger.info "Import votes to voting area #{@voting_area.name} (id: #{@voting_area_id})"
    vote_response = VotingApiRequest
                    .new(Vaalit::VotingApi::VOTES_URI)
                    .get

    VoteImporter
      .new(@voting_area)
      .create_votes!(vote_response.body)

    Delayed::Job.enqueue(CreateResultJob.new)
  end

end
