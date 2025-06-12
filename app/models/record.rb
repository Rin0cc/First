class Record < ApplicationRecord
  belongs_to :user
  belongs_to :user_flower

  validates :taask_name, presence: true
end
