class CandidateDrawsReadyJob
  def perform
    result = Result.freezed.first
    raise "Cannot mark candidate draws ready: no frozen result exists" if result.nil?

    Rails.logger.info "Marking candidate draws ready and calculating new alliance draws!"
    if result.candidate_draws_ready! == false
      raise "Cannot mark candidate draws ready: result is not frozen"
    end
  rescue StandardError
    Result.freezed.first&.processed!
    raise
  end

  # Precondition failures are permanent, do not retry.
  def max_attempts
    1
  end
end
