class CreateProfitabilityDaysAndProfitabilityYears < ActiveRecord::Migration
  def self.up
    create_table :profitability_days do |t|
      t.integer :project_id, :null => false
      t.date :day, :null => false
      t.decimal :effort_incurred, :null => false, :default => 0
      t.decimal :effort_scheduled, :null => false, :default => 0
      t.decimal :income_incurred, :null => false, :default => 0
      t.decimal :income_scheduled, :null => false, :default => 0
      t.decimal :external_cost_incurred, :null => false, :default => 0
      t.decimal :external_cost_scheduled, :null => false, :default => 0
      t.decimal :bpo_incurred, :null => false, :default => 0
      t.decimal :bpo_scheduled, :null => false, :default => 0
      t.timestamps
    end

    create_table :profitability_years do |t|
      t.integer :profitability_day_id, :null => false
      t.integer :year, :null => false
      t.decimal :effort_incurred, :null => false, :default => 0
      t.decimal :effort_scheduled, :null => false, :default => 0
      t.decimal :income_incurred, :null => false, :default => 0
      t.decimal :income_scheduled, :null => false, :default => 0
      t.decimal :external_cost_incurred, :null => false, :default => 0
      t.decimal :external_cost_scheduled, :null => false, :default => 0
      t.decimal :bpo_incurred, :null => false, :default => 0
      t.decimal :bpo_scheduled, :null => false, :default => 0
      t.timestamps
    end

    add_index :profitability_days, :project_id
    add_index :profitability_years, :profitability_day_id
  end

  def self.down
    drop_table :profitability_days
    drop_table :profitability_years
  end
end