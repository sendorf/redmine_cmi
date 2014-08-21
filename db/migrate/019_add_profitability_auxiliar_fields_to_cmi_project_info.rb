class AddProfitabilityAuxiliarFieldsToCmiProjectInfo < ActiveRecord::Migration
  def self.up
    add_column :cmi_project_infos, :total_bpo, :double, :null => false
    add_column :cmi_project_infos, :total_cost, :double, :null => false
    add_column :cmi_project_infos, :total_effort, :double, :null => false
  end

  def self.down
    remove_column :cmi_project_infos, :total_bpo
    remove_column :cmi_project_infos, :total_cost
    remove_column :cmi_project_infos, :total_effort
  end
end