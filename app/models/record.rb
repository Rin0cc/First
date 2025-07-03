class Record < ApplicationRecord
  belongs_to :user
  belongs_to :user_flower, optional: true # optional: true を追加した理由を後述

  # 時間記録の場合とToDoの場合でバリデーションを分ける
  # time が存在しない（nilか0）場合は task_name が必須
  # time が存在する（0より大きい）場合は task_name は必須ではない
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

  # モデルが作成される前に user_flower が存在するか確認する
  # これはRecordsController#set_user_flowerでUserFlowerが必ず設定されるため
  # モデルレベルで必須とする必要はないが、もし必要ならpresence: trueをtime_record? と task_only_record? のどちらかで制御する
  # current_user.user_flowers.build(record_params.merge(user: current_user)) で構築されるため、
  # Recordモデルでuser_flower_idの存在チェックは不要（またはconditional）
end