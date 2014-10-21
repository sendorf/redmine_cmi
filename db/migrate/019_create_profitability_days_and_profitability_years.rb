class CreateProfitabilityDaysAndProfitabilityYears < ActiveRecord::Migration
  def self.up
    create_table :profitability_days do |t|
      t.integer :project_id, :null => false
      t.date :day, :null => false
      t.float :effort_incurred, :null => false, :default => 0
      t.float :effort_scheduled, :null => false, :default => 0
      t.float :income_incurred, :null => false, :default => 0
      t.float :income_scheduled, :null => false, :default => 0
      t.float :external_cost_incurred, :null => false, :default => 0
      t.float :external_cost_scheduled, :null => false, :default => 0
      t.float :bpo_incurred, :null => false, :default => 0
      t.float :bpo_scheduled, :null => false, :default => 0
      t.timestamps
    end

    create_table :profitability_years do |t|
      t.integer :profitability_day_id, :null => false
      t.integer :year, :null => false
      t.float :effort_incurred, :null => false, :default => 0
      t.float :effort_scheduled, :null => false, :default => 0
      t.float :income_incurred, :null => false, :default => 0
      t.float :income_scheduled, :null => false, :default => 0
      t.float :external_cost_incurred, :null => false, :default => 0
      t.float :external_cost_scheduled, :null => false, :default => 0
      t.float :bpo_incurred, :null => false, :default => 0
      t.float :bpo_scheduled, :null => false, :default => 0
      t.timestamps
    end

    add_index :profitability_days, :project_id
    add_index :profitability_years, :profitability_day_id


    Project.all.each do |project|
    #Project.find([314,320,391]).each do |project|
    #project = Project.find([320])
      first_day = ProfitabilityDay.where(project_id: project.id).first_or_initialize
      #first_day = ProfitabilityDay.find_by_project_id(project.id) || ProfitabilityDay.create(project_id: project.id, day: Date.today)

      if first_day.new_record?
        metrics = CMI::Metrics.new
        
        first_day[:day] = Date.today
        first_day[:effort_incurred] = project.time_entries.inject(0.0){|sum, te| (te.cost) ? sum + te.cost : sum}
        metrics.project = project
        metrics.checkpoint = project.last_base_line
        metrics.date = Date.today
        first_day[:effort_scheduled] = metrics.hhrr_cost_scheduled + first_day[:effort_incurred]
        #first_day[:effort_scheduled] = first_day[:effort_incurred] + 0 #User.roles.inject(0.0) { |sum, role| sum = sum + (project.cmi_project_info.scheduled_role_effort(role))}
        
        first_day[:bpo_incurred] = metrics.bpo_cost_incurred
        first_day[:bpo_scheduled] = metrics.bpo_cost_scheduled

        if Setting.plugin_redmine_cmi['providers_tracker'].present? && Setting.plugin_redmine_cmi['providers_tracker_custom_field'].present? && Setting.plugin_redmine_cmi['providers_paid_statuses'].present? && Setting.plugin_redmine_cmi['providers_tracker_paid_date_custom_field'].present?
          incurred = 0.0
          remaining = 0.0
          project.issues.where('tracker_id = ?', Setting.plugin_redmine_cmi['providers_tracker']).each do |issue|
            value = issue.custom_field_value(Setting.plugin_redmine_cmi['providers_tracker_custom_field'])
            
            if Setting.plugin_redmine_cmi['providers_paid_statuses'].include?(issue.status_id.to_s)
              incurred += value.to_f
            else
              remaining += value.to_f
            end
          end

          first_day[:external_cost_incurred] = incurred
          first_day[:external_cost_scheduled] = incurred + remaining
        else
          puts "No se ha especificado el tracker para los proveedores por lo que no se ha podido cargar la información. Por favor, seleccione un tracker para proveedores y vuelva a actualizar el plugin"   
        end

        if Setting.plugin_redmine_cmi['bill_tracker'].present? && Setting.plugin_redmine_cmi['bill_amount_custom_field'].present? && Setting.plugin_redmine_cmi['bill_paid_statuses'].present? && Setting.plugin_redmine_cmi['bill_tracker_paid_date_custom_field'].present?
          incurred = 0.0
          remaining = 0.0
          project.issues.where('tracker_id = ?', Setting.plugin_redmine_cmi['bill_tracker']).each do |issue|
            value = issue.custom_field_value(Setting.plugin_redmine_cmi['bill_amount_custom_field'])            
            
            if Setting.plugin_redmine_cmi['bill_paid_statuses'].include?(issue.status_id.to_s)
              incurred += value.to_f
            else
              remaining += value.to_f
            end
          end
          first_day[:income_incurred] = incurred
          first_day[:income_scheduled] = incurred + remaining
        else
          puts "No se ha especificado el tracker para las facturas por lo que no se ha podido cargar la información. Por favor, seleccione un tracker para facturas y vuelva a actualizar el plugin"
        end

        first_day.save
      end
    end

  end

  def self.down
    drop_table :profitability_days
    drop_table :profitability_years
  end
end