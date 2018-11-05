class AllianceDrawsReadyJob
  def perform
    Result.alliance_draws_ready!
  end
end
