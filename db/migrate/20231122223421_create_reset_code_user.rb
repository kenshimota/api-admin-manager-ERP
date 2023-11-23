class CreateResetCodeUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :reset_code, :string, limit: 6
    add_column :users, :reset_code_sent_at, :datetime
  end
end
