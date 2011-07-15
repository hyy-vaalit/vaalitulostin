class Candidate < ActiveRecord::Base
  include RankedModel

  belongs_to :electoral_alliance
  ranks :sign_up_order, :with_same => :electoral_alliance_id

  belongs_to :faculty

end