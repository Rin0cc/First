class Record < ApplicationRecord
  belongs_to :user
  belongs_to :user_flower

  # validates :task_name, presence: true
end
