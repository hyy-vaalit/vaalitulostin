class CreateResultJob
  def perform
    Rails.logger.info "Creating a new non-final Result"
    result = Result.create!

    ResultPublisher.store_to_s3! result
  end
end
