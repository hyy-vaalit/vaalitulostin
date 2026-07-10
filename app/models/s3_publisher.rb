class S3Publisher
  def directory
    Vaalit::Results.directory
  end

  def bucket_name
    Vaalit::Results::AWS_S3_BUCKET_NAME
  end

  # AWS connection is established only in production mode.
  #
  # invalidate: must stay false for the recurring background jobs
  # (votes_* every 5 minutes) — constant invalidation would blow through
  # CloudFront's 1000 free paths/month. Only rare, human-triggered
  # publishes (results) should pass true.
  def store_s3_object(filename, contents, content_type = 'text/html', invalidate: false)
    if Vaalit::Aws::S3.connect?
      Rails.logger.info "Store to S3, bucket: '#{bucket_name}', dir: '#{directory}', filename: '#{filename}'"
      put_object(
        key: "#{directory}/#{filename}",
        body: contents,
        content_type: "#{content_type}; charset=utf-8"
      )
      invalidate_cdn!("/#{directory}/#{filename}") if invalidate
    else
      Rails.logger.debug "Development mode. Not storing to S3: #{filename}"
    end
  end

  def test_write
    put_object(
      key: "#{Vaalit::Results.directory}/lulz.txt",
      body: "Lulz UTF8 Ääkkönen: #{Time.now.utc}",
      content_type: 'text/html; charset=utf-8'
    )
  end

  def test_list_objects
    Vaalit::Aws::S3
      .client
      .list_objects bucket: Vaalit::Results::AWS_S3_BUCKET_NAME
  end

  private

  # Belt-and-suspenders: every file is uploaded with Cache-Control:
  # no-cache, so CloudFront revalidates it even without this. Invalidation
  # only protects against that header being dropped or the cache policy
  # being changed. No-op unless production AND
  # AWS_CLOUDFRONT_DISTRIBUTION_ID is set.
  def invalidate_cdn!(path)
    return unless Vaalit::Aws::CloudFront.connect?

    Rails.logger.info "Invalidating CloudFront path: #{path}"
    Vaalit::Aws::CloudFront.client.create_invalidation(
      distribution_id: Vaalit::Aws::CloudFront::DISTRIBUTION_ID,
      invalidation_batch: {
        paths: { quantity: 1, items: [path] },
        caller_reference: "#{path}-#{Time.now.to_i}"
      }
    )
  rescue Aws::Errors::ServiceError => e
    # Publishing must never fail because of the CDN; no-cache already
    # guarantees freshness.
    Rails.logger.error "CloudFront invalidation failed: #{e.message}"
  end

  def put_object(key:, body:, content_type:)
    Vaalit::Aws::S3
      .client
      .put_object(
        bucket: Vaalit::Results::AWS_S3_BUCKET_NAME,
        key: key,
        body: body,
        content_type: content_type,
        # CDNs/browsers must revalidate: a cached preliminary result must
        # never be served after the final one has been published.
        cache_control: 'no-cache'
      )
  end
end
