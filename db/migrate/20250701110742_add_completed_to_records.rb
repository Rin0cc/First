class AddCompletedToRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :records, :completed, :boolean, default: false, null: false
  end
end
