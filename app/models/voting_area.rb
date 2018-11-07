# Äänestysalueen tilat:
#
#  - "submitted": Näkyy adminille
#        Äänestysalueen kaikki äänet on laskettu
#        ja äänestysalueen pj on merkinnyt alueen syötetyksi.
#        Admin voi valita äänestysalueen äänet mukaan seuraavaan tulokseen.
#  - "ready": Näkyy workerille
#        Admin on merkinnyt äänestysalueen otettavaksi mukaan, kun seuraava
#        (väliaika)tulos lasketaan.
#
# Hyvä tietää:
#  - vasta äänestysalueen merkitseminen valmiiksi (submitted) estää
#    uusien äänien syöttämisen kyseiselle alueelle.
#
class VotingArea < ApplicationRecord
  has_many :votes

  validates :code, uniqueness: true

  scope :countable, -> { where('ready = ?', true) }
  scope :markable_as_ready, -> { where('submitted = ?', true) }
  scope :by_code, -> { order(:code) }

  def vote_count
    votes.sum(:amount)
  end

  def ready!
    update! ready: true
  end

  def submitted!
    update! submitted: true
  end
end
