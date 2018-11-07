class S3Publisher
  def directory
    Vaalit::Results::DIRECTORY
  end

  def bucket_name
    Vaalit::Results::S3_BUCKET_NAME
  end

  # AWS connection is established only in production mode
  def store_s3_object(filename, contents, content_type = 'text/html')
    if Vaalit::AWS.connect?
      Rails.logger.info "Store to S3, bucket: '#{bucket_name}', dir: '#{directory}', filename: '#{filename}'"
      AWS::S3::S3Object.store(
        "#{directory}/#{filename}",
        contents,
        bucket_name,
        content_type: "#{content_type}; charset=utf-8"
      )
    else
      Rails.logger.debug "Development mode. Not storing to S3: #{filename}"
    end
  end

  def test_connection
    AWS::S3::S3Object.store(
      "#{Vaalit::Results::DIRECTORY}/lulz.txt",
      "Lulz: #{Time.now.utc}",
      Vaalit::Results::S3_BUCKET_NAME,
      content_type: 'text/html; charset=utf-8'
    )
  end
end
