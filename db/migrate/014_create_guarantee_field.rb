class CreateGuaranteeField < ActiveRecord::Migration
  def self.up
    add_column :cmi_project_infos, :guarantee, :integer, :null => false
  end

  def self.down
    remove_column :cmi_project_infos, :guarantee
  end
end
