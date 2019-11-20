class JudgementSet < ApplicationRecord
  belongs_to :user
  has_many :scores
end
