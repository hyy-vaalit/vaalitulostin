class CreateFrozenResultJob
  def perform
    Result.freeze_for_draws!
  end
end
