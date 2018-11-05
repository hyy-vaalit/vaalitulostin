class CreateFinalResultJob

  def perform
    Rails.logger.info "Creating the Final Result"
    result = Result.finalize!

    Rails.logger.info "Publishing the Final Result"
    ResultPublisher.store_to_s3!(result)
  end

end
