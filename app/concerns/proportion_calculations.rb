module ProportionCalculations
  extend ActiveSupport::Concern

  included do
    def self.calculate_proportional(votes, array_index)
      (votes.to_f / (array_index + 1)).round(Vaalit::Voting::PROPORTIONAL_PRECISION)
    end
  end

  module ClassMethods
    def create_or_update!(result_id:, candidate_id:, number:)
      existing =
        where(candidate_id: candidate_id)
        .find_by(result_id: result_id)

      if existing.present?
        existing.update_attributes!(number: number)
      else
        self.create!(
          result_id: result_id,
          candidate_id: candidate_id,
          number: number
        )
      end
    end
  end
end
