class CreateFinalResultJob
  def perform
    result = Result.finalize!

    ResultPublisher.store_to_s3!(result)
  end
end
