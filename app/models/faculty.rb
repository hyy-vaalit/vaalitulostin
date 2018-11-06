class Faculty < ApplicationRecord
  has_many :candidates

  validates :name, :code, presence: true
end
