RSpec.describe S3Publisher, type: :model do
  let(:publisher) { S3Publisher.new }

  describe "#store_s3_object" do
    it "does not contact AWS outside production" do
      expect(Aws::S3::Client).not_to receive(:new)
      expect(Aws::CloudFront::Client).not_to receive(:new)
      publisher.store_s3_object('result.html', '<html/>', invalidate: true)
    end

    context "in production with a distribution id" do
      let(:s3_client) { instance_double(Aws::S3::Client, put_object: true) }
      let(:cdn_client) { instance_double(Aws::CloudFront::Client) }

      before do
        allow(Vaalit::Aws::S3).to receive(:connect?).and_return(true)
        allow(Vaalit::Aws::S3).to receive(:client).and_return(s3_client)
        stub_const("Vaalit::Aws::CloudFront::DISTRIBUTION_ID", "EDISTRIBUTION")
        allow(Vaalit::Aws::CloudFront).to receive(:client).and_return(cdn_client)
      end

      it "does not invalidate by default (recurring background jobs)" do
        expect(cdn_client).not_to receive(:create_invalidation)

        publisher.store_s3_object('votes_by_hour.json', '{}', 'application/json')
      end

      it "invalidates the uploaded file when asked to" do
        expect(cdn_client).to receive(:create_invalidation).with(
          hash_including(
            distribution_id: "EDISTRIBUTION",
            invalidation_batch: hash_including(
              paths: {
                quantity: 1,
                items: ["/#{Vaalit::Results.directory}/result.html"]
              }
            )
          )
        )

        publisher.store_s3_object('result.html', '<html/>', invalidate: true)
      end

      it "never fails the publish on a CDN error" do
        allow(cdn_client).to receive(:create_invalidation)
          .and_raise(Aws::Errors::ServiceError.new(nil, "boom"))

        expect { publisher.store_s3_object('result.html', '<html/>', invalidate: true) }
          .not_to raise_error
      end
    end
  end
end
