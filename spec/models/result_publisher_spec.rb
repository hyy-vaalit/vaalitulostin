RSpec.describe ResultPublisher, type: :model do
  let(:result) { instance_double(Result, id: 42) }
  let(:publisher) { ResultPublisher.new(result) }

  describe "#invalidate_cdn!" do
    it "does not contact AWS outside production" do
      expect(Aws::CloudFront::Client).not_to receive(:new)
      publisher.send(:invalidate_cdn!)
    end

    context "in production with a distribution id" do
      let(:client) { instance_double(Aws::CloudFront::Client) }

      before do
        allow(Vaalit::Aws::S3).to receive(:connect?).and_return(true)
        stub_const("Vaalit::Aws::CloudFront::DISTRIBUTION_ID", "EDISTRIBUTION")
        allow(Vaalit::Aws::CloudFront).to receive(:client).and_return(client)
      end

      it "invalidates the year directory" do
        expect(client).to receive(:create_invalidation).with(
          hash_including(
            distribution_id: "EDISTRIBUTION",
            invalidation_batch: hash_including(
              paths: { quantity: 1, items: ["/#{Vaalit::Results.directory}/*"] }
            )
          )
        )

        publisher.send(:invalidate_cdn!)
      end

      it "never fails the publish on a CDN error" do
        allow(client).to receive(:create_invalidation)
          .and_raise(Aws::Errors::ServiceError.new(nil, "boom"))

        expect { publisher.send(:invalidate_cdn!) }.not_to raise_error
      end
    end
  end
end
