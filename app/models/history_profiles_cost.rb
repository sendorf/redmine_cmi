class HistoryProfilesCost < ActiveRecord::Base
	validates :value, :numericality => true

	def edit(value)
		self.value = value
		self.save
	end
end
