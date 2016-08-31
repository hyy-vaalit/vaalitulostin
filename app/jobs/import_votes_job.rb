require './lib/fetch_votes_from_voting_api'

class ImportVotesJob

  def initialize(voting_area)
    @voting_area = voting_area
  end

  def perform
    Rails.logger.info "Import votes to voting area #{@voting_area.name} (id: #{@voting_area_id})"

    response = FetchVotesFromVotingApi.new.get

    VoteImporter
      .new(@voting_area)
      .create_votes!(response.body)

    Delayed::Job.enqueue(CreateResultJob.new)
  end

end
