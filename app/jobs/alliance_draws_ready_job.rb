class AllianceDrawsReadyJob
  def perform
    result = Result.freezed.first
    raise "Cannot mark alliance draws ready: no frozen result exists" if result.nil?

    Rails.logger.info "Marking alliance draws ready and calculating new coalition draws!"
    if result.alliance_draws_ready! == false
      raise "Cannot mark alliance draws ready: candidate draws are not ready"
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
