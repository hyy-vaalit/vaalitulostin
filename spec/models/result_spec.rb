RSpec.describe Result, type: :model do
  describe "#candidate_draws_ready!" do
    let(:result) { FactoryBot.create :result, freezed: true }
    let(:draw) { CandidateDraw.create! result: result, identifier_number: 0 }

    before do
      2.times do
        CandidateResult.create!(
          result: result,
          candidate: FactoryBot.create(:candidate),
          vote_sum_cache: 10,
          candidate_draw: draw
        )
      end
    end

    it "raises when a candidate draw has no order values" do
      expect { result.candidate_draws_ready! }
        .to raise_error(/missing or duplicate candidate_draw_order/)
      expect(result.reload.candidate_draws_ready).to eq false
    end

    it "raises when a candidate draw has duplicate order values" do
      result.candidate_results.each { |cr| cr.update! candidate_draw_order: 1 }

      expect { result.candidate_draws_ready! }
        .to raise_error(/missing or duplicate candidate_draw_order/)
    end

    it "advances when every draw has a complete permutation" do
      result.candidate_results.each_with_index do |cr, i|
        cr.update! candidate_draw_order: i + 1
      end

      expect(result.candidate_draws_ready!).to eq result
      expect(result.reload.candidate_draws_ready).to eq true
    end
  end

  describe "draw recreation" do
    let(:result) { FactoryBot.create :result }

    it "clears stale alliance and coalition draw orders" do
      candidate_result = CandidateResult.create!(
        result: result,
        candidate: FactoryBot.create(:candidate),
        vote_sum_cache: 10,
        alliance_draw_order: 2,
        coalition_draw_order: 3
      )

      result.send(:create_alliance_draws!)
      result.send(:create_coalition_draws!)

      candidate_result.reload
      expect(candidate_result.alliance_draw_order).to be_nil
      expect(candidate_result.coalition_draw_order).to be_nil
    end
  end
end
