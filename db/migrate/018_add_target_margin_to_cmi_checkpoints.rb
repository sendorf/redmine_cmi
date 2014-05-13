class AddTargetMarginToCmiCheckpoints < ActiveRecord::Migration
  def self.up
    add_column :cmi_checkpoints, :target_margin, :integer, :null => false
  end

  def self.down
    remove_column :cmi_checkpoints, :target_margin
  end
end