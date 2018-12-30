class AddColumnStatusToComplaints < ActiveRecord::Migration[5.2]
  def change
    add_column :complaints, :status, :string, default: 'Pending'
  end
end
