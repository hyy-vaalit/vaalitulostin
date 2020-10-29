class PublishVotesByHourJob
  attr_accessor :json_data

  def initialize(json_data)
    self.json_data = json_data
  end

  def perform
    Rails.logger.info "Store JSON votes by hour to S3"

    S3Publisher
      .new
      .store_s3_object('votes_by_hour.json', json_data, 'application/json')

    Rails.logger.info 'Reschedule next import of votes by hour'
    Delayed::Job.enqueue(ImportVotesByHourJob.new, run_at: 5.minutes.from_now)
  end
end
