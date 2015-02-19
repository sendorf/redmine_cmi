class AddBaseLineToCmiCheckpoints < ActiveRecord::Migration
  def self.up
    add_column :cmi_checkpoints, :base_line, :boolean, :null => false
  end

  def self.down
    remove_column :cmi_checkpoints, :base_line
	create_table :cmi_project_efforts do |t|
      t.references :cmi_project_info, :null => false
      t.string :role, :null => false
      t.float :scheduled_effort, :null => false, :default => 0
      t.timestamps
    end

    add_index :cmi_project_efforts, [:cmi_project_info_id, :role], :unique => true
  end
end
