RSpec.describe "Proportional tie detection", type: :model do
  # The result must exist before the candidates: creating a Result runs
  # calculate! which would otherwise generate proportionals for them.
  let!(:result) { FactoryBot.create :result }
  let!(:candidates) { Array.new(2) { FactoryBot.create :candidate } }

  # 1/3 and 33333/100000 both display as 0.33333 but are not a tie.
  it "does not report a false tie for distinct fractions rounding alike" do
    CoalitionProportional.create!(
      result: result, candidate: candidates[0],
      number: 0.33333, numerator: 1, denominator: 3
    )
    CoalitionProportional.create!(
      result: result, candidate: candidates[1],
      number: 0.33333, numerator: 33333, denominator: 100_000
    )

    expect(CoalitionProportional.find_duplicate_numbers(result.id)).to be_empty
  end

  it "reports a true tie for equal fractions" do
    candidates.each do |candidate|
      CoalitionProportional.create!(
        result: result, candidate: candidate,
        number: 15.0, numerator: 15, denominator: 1
      )
    end

    groups = CoalitionProportional.find_duplicate_numbers(result.id)
    expect(groups.length).to eq 1

    ids = CoalitionProportional.find_draw_candidate_ids_of(groups.first, result.id)
    expect(ids.sort).to eq candidates.map(&:id).sort
  end
end
