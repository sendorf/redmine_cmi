class RemoveCmiExpenditures < ActiveRecord::Migration
  def self.up
    drop_table :cmi_expenditures
  end

  def self.down
    create_table :cmi_expenditures do |t|
      t.integer :project_id, :null => false
      t.integer :author_id, :null => false
      t.string :concept, :null => false
      t.text :description
      t.integer :initial_budget, :null => false
      t.integer :current_budget, :null => false
      t.integer :incurred, :null => false, :default => 0
      t.timestamps
    end

    add_index :cmi_expenditures, :project_id
  end
end