class VoteImporter
  def initialize(voting_area)
    if voting_area.votes.countable_sum.nonzero?
      raise "Expected voting area not to have any votes (has #{voting_area.votes.countable_sum} votes)"
    end

    @voting_area = voting_area
  end

  # Data:
  # ehdokasnumero,ehdokasnimi,ääniä,vaaliliitto,vaaliliiton id
  # with header
  def create_votes!(csv)
    ActiveRecord::Base.transaction do
      begin
        row_count = 0
        CSV.parse(csv, headers: true, col_sep: ",") do |row|
          ImportedCsvVote.create_from! row, voting_area_id: @voting_area.id
          row_count += 1
        end

        # An HTTP error body parses as a header-only CSV. Without this guard
        # a zero-vote "result" would be calculated and published as real.
        raise "Expected vote CSV to contain data rows, got none" if row_count.zero?

        @voting_area.submitted!
        @voting_area.ready!
      rescue Exception => e
        Rails.logger.error "Failed importing votes: #{e.message}"
        raise e
      end
    end
  end
end
