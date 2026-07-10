# Flow:
#
# set status to pending
# create aws s3 job
# job calls actual publish method:
#   - uploads Result#to_html to s3
#   - uploads Result#to_json to s3
#   - sets published=true if result is made "public" (ie. index.html or index.json),
#     otherwise uses unique filename
class ResultPublisher
  def initialize(result)
    @result = result
    @s3_publisher = S3Publisher.new
  end

  def self.store_to_s3!(result)
    Rails.logger.info "Publishing Result (id: #{result.id}) to Amazon S3"
    self.new(result).store_to_s3!
  end

  def publish!
    Result.transaction do
      @result.published_pending!
      Delayed::Job.enqueue(PublishResultJob.new(@result.id))
    end
  end

  def store_and_make_public!
    Rails.logger.info "Publishing a previously created result (id: #{@result.id})."

    # S3 uploads must not run inside a DB transaction: they are slow,
    # cannot be rolled back, and would hold the transaction open.
    @result.published!
    store_to_s3!
  end

  def store_to_s3!
    Rails.logger.info "Rendering result output"
    decorated_result = ResultDecorator.decorate(@result)

    # Data files first, result.html last: the human-visible artifact must
    # never be newer than the data it links to. No atomicity across
    # uploads exists in S3.
    @s3_publisher.store_s3_object(better_filename('.json'), decorated_result.to_json)
    @s3_publisher.store_s3_object(
      better_filename('.json', 'candidates'),
      decorated_result.to_json_candidates
    )
    @s3_publisher.store_s3_object(better_filename('.html'), decorated_result.to_html)

    invalidate_cdn!
  end

  private

  # Belt-and-suspenders: every published file is uploaded with
  # Cache-Control: no-cache, so CloudFront revalidates it even without
  # this. Invalidation only protects against that header being dropped.
  # No-op unless production AND AWS_CLOUDFRONT_DISTRIBUTION_ID is set.
  def invalidate_cdn!
    return unless Vaalit::Aws::CloudFront.connect?

    Rails.logger.info "Invalidating CloudFront path: /#{directory}/*"
    Vaalit::Aws::CloudFront.client.create_invalidation(
      distribution_id: Vaalit::Aws::CloudFront::DISTRIBUTION_ID,
      invalidation_batch: {
        paths: { quantity: 1, items: ["/#{directory}/*"] },
        caller_reference: "result-#{@result.id}-#{Time.now.to_i}"
      }
    )
  rescue Aws::Errors::ServiceError => e
    # Publishing must never fail because of the CDN; no-cache already
    # guarantees freshness.
    Rails.logger.error "CloudFront invalidation failed: #{e.message}"
  end

  def better_filename(suffix, name = "result")
    @result.published? ? public_filename(suffix, name) : unique_filename(suffix, name)
  end

  def directory
    Vaalit::Results.directory
  end

  def bucket_name
    Vaalit::Results::AWS_S3_BUCKET_NAME
  end

  def public_filename(suffix, name)
    "#{name}#{suffix}"
  end

  def unique_filename(suffix, name)
    @result.filename(suffix, name)
  end
end
