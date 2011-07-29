# == Schema Information
# Schema version: 20110610034250
#
# Table name: visits
#
#  id          :integer         not null, primary key
#  patient_id  :integer
#  date        :date
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Visit < ActiveRecord::Base
  attr_accessible :date

  belongs_to :patient

  validates :patient, :presence => true
  validates :date, :presence => true
end
