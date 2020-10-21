class S3Publisher
  def directory
    Vaalit::Results::DIRECTORY
  end

  def bucket_name
    Vaalit::Results::AWS_S3_BUCKET_NAME
  end

  # AWS connection is established only in production mode
  def store_s3_object(filename, contents, content_type = 'text/html')
    if Vaalit::Aws::S3.connect?
      Rails.logger.info "Store to S3, bucket: '#{bucket_name}', dir: '#{directory}', filename: '#{filename}'"
      put_object(
        key: "#{directory}/#{filename}",
        body: contents,
        content_type: "#{content_type}; charset=utf-8"
      )
    else
      Rails.logger.debug "Development mode. Not storing to S3: #{filename}"
    end
  end

  def test_write
    put_object(
      key: "#{Vaalit::Results::DIRECTORY}/lulz.txt",
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

  def put_object(key:, body:, content_type:)
    Vaalit::Aws::S3
      .client
      .put_object(
        bucket: Vaalit::Results::AWS_S3_BUCKET_NAME,
        key: key,
        body: body,
        content_type: content_type
      )
  end
end
