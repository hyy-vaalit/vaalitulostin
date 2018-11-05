class CandidateDrawsReadyJob
  def perform
    Result.candidate_draws_ready!
  end
end
