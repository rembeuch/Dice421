class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :pseudo, presence: true , length: { maximum: 20 }, uniqueness: true
end
