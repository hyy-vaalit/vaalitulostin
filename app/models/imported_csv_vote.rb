class ImportedCsvVote
  attr_accessor :candidate_number,
                :vote_count

  def self.create_from!(source, voting_area_id:)
    imported = build_from source

    Vote.create!(
      candidate: Candidate.find_by!(candidate_number: imported.candidate_number),
      amount: imported.vote_count,
      voting_area_id: voting_area_id
    )
  end

  def self.build_from(source)
    new.tap { |imported| imported.convert(source) }
  end

  # Data is
  # ehdokasnumero,ehdokasnimi,ääniä,vaaliliitto,vaaliliiton id
  #   0              1          2     3            4
  def convert(data)
    # Integer() raises on malformed input where to_i would silently
    # truncate ("1O0" -> 1) or zero (""), corrupting the count.
    @candidate_number = Integer(data[0].strip, 10)
    @vote_count = Integer(data[2].strip, 10)
  end
end
