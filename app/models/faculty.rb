class Faculty < ApplicationRecord
  has_many :candidates

  validates_presence_of :name, :code
end
