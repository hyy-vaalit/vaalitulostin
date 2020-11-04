class PublishVotesByVoterStartYearJob
  attr_accessor :json_data

  def initialize(json_data)
    self.json_data = json_data
  end

  def perform
    Rails.logger.info 'Store JSON votes by voter start year to S3'

    S3Publisher
      .new
      .store_s3_object('votes_by_voter_start_year.json', json_data, 'application/json')

    Rails.logger.info 'Reschedule next import of votes by voter start year'
    Delayed::Job.enqueue(ImportVotesByVoterStartYearJob.new, run_at: 5.minutes.from_now)
  end
end
