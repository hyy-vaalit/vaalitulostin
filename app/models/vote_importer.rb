class VoteImporter

  def initialize(voting_area)
    @voting_area = voting_area

    if @voting_area.votes.countable_sum.nonzero?
      raise "Expected voting area not to have any votes (has #{@voting_area.votes.countable_sum} votes)"
    end
  end

  # Data:
  # ehdokasnumero,ehdokasnimi,ääniä,vaaliliitto,vaaliliiton id
  # with header
  def create_votes!(csv)
    ActiveRecord::Base.transaction do
      begin
        CSV.parse(csv, headers: true, col_sep: ",") do |row|
          ImportedCsvVote.create_from! row, voting_area_id: @voting_area.id
        end

        @voting_area.submitted!
        @voting_area.ready!
      rescue Exception => e
        Rails.logger.error "Failed importing votes: #{e.message}"
        raise ActiveRecord::Rollback
      end
    end
  end

end
