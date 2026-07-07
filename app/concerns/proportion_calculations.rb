module ProportionCalculations
  extend ActiveSupport::Concern

  included do
    # Display value only. Two distinct proportionals can round to the
    # same 5 decimals (difference can be as small as 1/(i*j)); ties are
    # detected from the exact fraction below, never from this number.
    def self.calculate_proportional(votes, array_index)
      (votes.to_f / (array_index + 1)).round(Vaalit::Voting::PROPORTIONAL_PRECISION)
    end

    # Exact value of the proportional as a reduced fraction.
    def self.proportional_fraction(votes, array_index)
      Rational(votes, array_index + 1)
    end
  end

  module ClassMethods
    def create_or_update!(result_id:, candidate_id:, number:, numerator:, denominator:)
      existing =
        where(candidate_id: candidate_id)
        .find_by(result_id: result_id)

      if existing.present?
        existing.update!(number: number, numerator: numerator, denominator: denominator)
      else
        self.create!(
          result_id: result_id,
          candidate_id: candidate_id,
          number: number,
          numerator: numerator,
          denominator: denominator
        )
      end
    end
  end
end
