describe CandidateResult do
  it 'finds duplicate vote sums in the same alliance' do
    alliance = FactoryBot.create(:electoral_alliance_with_candidates)

    result = FactoryBot.create(:result)
    described_class.destroy_all # Creating a result also creates the CandidateResults

    draw_votes = 100

    VotableSupport.create_candidate_draws(alliance, result, draw_votes)

    draws = described_class.find_duplicate_vote_sums(result)
    expect(draws.first.vote_sum_cache).to eq draw_votes
    expect(draws.length).to eq 1
  end
end
