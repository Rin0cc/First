class AddTimeToRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :records, :time, :integer
  end
end
