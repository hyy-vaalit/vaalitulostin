# Publish votes in S3 at the earliest possible moment, eg. right after votes have been imported
# from the API. To avoid leaking the votes before the final result has been published, a private
# filename is used. Publishing votes right after importing them serves a backup purpose.
#
# The final votes are published in S3 when they are committed in the vaalitulos.hyy.fi repository.
class PublishVotesJob
  attr_accessor :csv_data, :private_filename

  def initialize(csv_data, private_filename:)
    self.csv_data = csv_data
    self.private_filename = private_filename
  end

  def perform
    Rails.logger.info "Store CSV Votes to S3"

    S3Publisher
      .new
      .store_s3_object(filename, csv_data, 'text/csv')
  end

  private

  # Private filename ensures votes.csv is not accessible before the final result is published.
  def filename
    if private_filename
      "votes-#{SecureRandom.hex(20)}.csv"
    else
      "votes.csv"
    end
  end
end
