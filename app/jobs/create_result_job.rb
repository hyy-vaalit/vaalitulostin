class CreateResultJob

  def perform
    Rails.logger.info "Creating a new Result"
    result = Result.create!

    Rails.logger.info "Publishing a new midterm Result"
    ResultPublisher.store_to_s3! result
  end

end
