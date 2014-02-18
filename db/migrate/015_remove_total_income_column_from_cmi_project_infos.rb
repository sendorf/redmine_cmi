class RemoveTotalIncomeColumnFromCmiProjectInfos < ActiveRecord::Migration
  def self.up
    remove_column :cmi_project_infos, :total_income
  end

  def self.down
    add_column :cmi_project_infos, :total_income, :precision => 12, :scale => 2, :null => false
  end
end
