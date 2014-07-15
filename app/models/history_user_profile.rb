class HistoryUserProfile < ActiveRecord::Base
  validates :created_on, :presence => true, 
              :format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }
  validates :finished_on, :allow_nil => true, 
              :format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }

  belongs_to :user
end
