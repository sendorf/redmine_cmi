class HistoryProfilesCost < ActiveRecord::Base
	def edit(value)
		self.value = value
		self.save
	end
end
