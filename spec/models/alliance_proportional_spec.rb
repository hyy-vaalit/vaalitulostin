describe AllianceProportional do
  it 'gives /n of the votes of an alliance to the candidate with nth most votes as an alliance proportional' do
    allow(CoalitionProportional).to receive(:calculate!)
    coalition = FactoryGirl.create(:electoral_coalition_with_alliances_and_candidates)
    alliance = coalition.electoral_alliances.first
    total_vote_sum = 1235

    ElectoralCoalition.should_receive(:all).and_return([coalition])
    coalition.should_receive(:electoral_alliances).and_return([alliance])
    alliance.candidates.should_receive(:with_vote_sums_for).and_return(alliance.candidates)
    alliance.votes.should_receive(:countable_sum).and_return(total_vote_sum)

    FactoryGirl.create(:result)

    # Reversed array order: Last candidate has the biggest proportional number
    alliance.candidates.reverse.each_with_index do |candidate, index|
      expect(candidate.alliance_proportionals.last.number)
        .to eq(
          (total_vote_sum.to_f / (alliance.candidates.count - index))
            .round(Vaalit::Voting::PROPORTIONAL_PRECISION)
        )
    end
  end
end
