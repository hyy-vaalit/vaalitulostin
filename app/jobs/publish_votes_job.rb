class PublishVotesJob

  attr_accessor :csv_data

  def initialize(csv_data)
    self.csv_data = csv_data
  end

  def perform
    Rails.logger.info "Store CSV Votes to S3"

    S3Publisher
      .new()
      .store_s3_object("votes.csv", csv_data, 'text/csv')
  end

end
