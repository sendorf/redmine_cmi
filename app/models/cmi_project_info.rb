class CmiProjectInfo < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_many :cmi_project_efforts, :dependent => :destroy, :inverse_of => :cmi_project_info

  accepts_nested_attributes_for :cmi_project_efforts, :allow_destroy => true

  validates_presence_of :project

  validates_format_of :actual_start_date, :with => /^\d{4}-\d{2}-\d{2}$/, :message => :not_a_date, :allow_nil => true
  validates_format_of :scheduled_start_date, :with => /^\d{4}-\d{2}-\d{2}$/, :message => :not_a_date, :allow_nil => false
  validates_format_of :scheduled_finish_date, :with => /^\d{4}-\d{2}-\d{2}$/, :message => :not_a_date, :allow_nil => false

  validates_numericality_of :scheduled_qa_meetings, :only_integer => true
  validates_numericality_of :total_income
  validates_numericality_of :guarantee, :only_integer => true
  validates_inclusion_of :guarantee, :in => (0..24), :message => :not_in_range
  validate :role_efforts

  def scheduled_role_effort(role)
    effort = cmi_project_efforts.detect{ |effort| effort.role == role }
    effort.nil? ? 0.0 : effort.scheduled_effort
  end

  def scheduled_role_effort_id(role)
    effort = cmi_project_efforts.detect{ |effort| effort.role == role }
    effort.nil? ? nil : effort.id
  end

  def cmi_project_efforts_attributes_with_auto_delete=(attrs)
    @cmi_project_efforts_attributes = attrs
    cmi_project_efforts.each do |old|
      old.mark_for_destruction unless attrs.detect {|new| new["role"] == old.role}
    end
    self.cmi_project_efforts_attributes_without_auto_delete = attrs
  end
  alias_method_chain :cmi_project_efforts_attributes=, :auto_delete

  def total_income
    factura_tracker_id = Setting.plugin_redmine_cmi['bill_tracker']
    cantidad_facturada_id = Setting.plugin_redmine_cmi['bill_amount_custom_field']

    amount = 0.0
    
    if factura_tracker_id.present? && cantidad_facturada_id.present?
      facturas = Issue.find_all_by_project_id_and_tracker_id(project.id, factura_tracker_id)
      amount = CustomValue.sum(:value, 
                               :conditions => {:custom_field_id => cantidad_facturada_id, 
                                               :customized_id => facturas.collect{|f| f.id}
                                              }
                              )
    end

    amount.to_f
  end

  private

  # Role efforts validation
  def role_efforts
    User.roles.each do |role|
      attr = @cmi_project_efforts_attributes.try(:detect){ |effort| effort['role'] == role }
      if attr
        begin
          Kernel.Float attr['scheduled_effort']
        rescue ArgumentError
          error = [I18n.translate(:"cmi.label_scheduled_role_effort", :role => role),
                   I18n.translate(:"activerecord.errors.messages.not_a_number")].join " "
          errors.add_to_base(error)
        end
      end
    end
  end
end
