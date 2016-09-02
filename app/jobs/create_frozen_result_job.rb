class CreateFrozenResultJob

  def perform
    Rails.logger.info "Creating the Frozen Result (it will not be stored in S3)"
    Result.freeze_for_draws!
  end

end
