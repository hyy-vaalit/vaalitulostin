RSpec.describe Vote, type: :model do
  describe "freeze integrity" do
    it "forbids creating or changing votes while a frozen result exists" do
      vote = FactoryBot.create :vote

      FactoryBot.create :result, freezed: true

      expect { vote.update! fixed_amount: 999 }
        .to raise_error(/frozen or final result/)
      expect { FactoryBot.create :vote }
        .to raise_error(/frozen or final result/)
      expect { vote.destroy! }
        .to raise_error(/frozen or final result/)
    end

    it "forbids marking a voting area ready while a frozen result exists" do
      area = FactoryBot.create :voting_area, ready: false, submitted: true

      FactoryBot.create :result, freezed: true

      expect { area.ready! }.to raise_error(/frozen or final result/)
      expect(area.reload.ready).to eq false
    end
  end
end
