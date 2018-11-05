class ImportedCsvVote
  attr_accessor :candidate_number,
                :vote_count

  def self.create_from!(source, voting_area_id:)
    imported = build_from source

    Vote.create!(
      candidate:      Candidate.find_by_candidate_number!(imported.candidate_number),
      amount:         imported.vote_count,
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
    @candidate_number = data[0].strip.to_i
    @vote_count       = data[2].strip.to_i
  end
end
