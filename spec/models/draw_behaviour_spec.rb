RSpec.describe DrawBehaviour, type: :model do
  let(:result) { FactoryBot.create :result }
  let(:draw) { CandidateDraw.create! result: result, identifier_number: 0 }
  let(:candidate_results) do
    Array.new(3) do
      CandidateResult.create!(
        result: result,
        candidate: FactoryBot.create(:candidate),
        vote_sum_cache: 10,
        candidate_draw: draw
      )
    end
  end
  let(:ids) { candidate_results.map(&:id) }

  describe "#give_order!" do
    it "stores a valid permutation of 1..n" do
      draw.give_order!(:candidate_draw_order, { ids[0] => "2", ids[1] => "3", ids[2] => "1" })

      expect(candidate_results.map { |cr| cr.reload.candidate_draw_order }).to eq [2, 3, 1]
    end

    it "raises on blank order values" do
      expect {
        draw.give_order!(:candidate_draw_order, { ids[0] => "", ids[1] => "1", ids[2] => "2" })
      }.to raise_error(DrawBehaviour::InvalidDrawOrder)
    end

    it "raises on non-numeric order values" do
      expect {
        draw.give_order!(:candidate_draw_order, { ids[0] => "abc", ids[1] => "1", ids[2] => "2" })
      }.to raise_error(DrawBehaviour::InvalidDrawOrder)
    end

    it "raises on duplicate order values" do
      expect {
        draw.give_order!(:candidate_draw_order, { ids[0] => "1", ids[1] => "1", ids[2] => "2" })
      }.to raise_error(DrawBehaviour::InvalidDrawOrder)
    end

    it "raises when a draw member is missing from the submitted orders" do
      expect {
        draw.give_order!(:candidate_draw_order, { ids[0] => "1", ids[1] => "2" })
      }.to raise_error(DrawBehaviour::InvalidDrawOrder)
    end

    it "raises when orders are not 1..n" do
      expect {
        draw.give_order!(:candidate_draw_order, { ids[0] => "1", ids[1] => "2", ids[2] => "4" })
      }.to raise_error(DrawBehaviour::InvalidDrawOrder)
    end

    it "writes nothing when validation fails" do
      begin
        draw.give_order!(:candidate_draw_order, { ids[0] => "1", ids[1] => "2", ids[2] => "x" })
      rescue DrawBehaviour::InvalidDrawOrder
        nil
      end

      expect(candidate_results.map { |cr| cr.reload.candidate_draw_order }).to eq [nil, nil, nil]
    end
  end
end
