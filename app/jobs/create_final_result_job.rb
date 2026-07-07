class CreateFinalResultJob
  def perform
    result = Result.freezed.first
    raise "Cannot finalize: no frozen result exists" if result.nil?

    Rails.logger.info "Creating the Final Result"
    if result.finalize! == false
      raise "Cannot finalize: alliance draws have not been marked ready"
    end

    ResultPublisher.store_to_s3!(result)
  rescue StandardError
    Result.freezed.first&.processed!
    raise
  end

  # Precondition failures are permanent; retrying would only let a stale
  # job finalize the election unexpectedly later.
  def max_attempts
    1
  end
end
