class ElectoralCoalition < ApplicationRecord
  has_many :coalition_results
  has_many :results, :through => :coalition_results

  has_many :electoral_alliances, :dependent => :nullify
  has_many :candidates, :through => :electoral_alliances

  validates :name, :shorten, presence: true

  scope :by_numbering_order, -> { order("#{table_name}.numbering_order") }

  def preliminary_vote_sum
    electoral_alliances.map(&:votes).map(&:preliminary_sum).sum # did not work with sql the same way as in alliances
  end

  def countable_vote_sum
    electoral_alliances.map(&:votes).map(&:countable_sum).sum # sql trololooo
  end
end
