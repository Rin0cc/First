# app/models/record.rb

class Record < ApplicationRecord
  belongs_to :user
  belongs_to :user_flower, optional: true

  scope :completed, -> { where(completed: true) }

  scope :incomplete, -> { where(completed: false) }

  validates :task_name, presence: true, unless: :time_record?
  validates :time, presence: true, numericality: { greater_than_or_equal_to: 0 }, unless: :task_only_record?

  # 時間記録であるかを判定するヘルパーメソッド
  def time_record?
    time.present? && time > 0
  end

  # ToDoのみの記録であるかを判定するヘルパーメソッド
  def task_only_record?
    task_name.present? && (time.nil? || time == 0)
  end
end
