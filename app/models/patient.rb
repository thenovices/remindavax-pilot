class Patient < ActiveRecord::Base
  attr_accessible :name, :husband_name, :mother_age, :subcenter_id, :village, :anm_id, :asha_id, :mobile, :cell_access,
    :taayi_card_number, :ec_number, :expected_delivery_date, :caste, :education, :delivery_place

  belongs_to :phc
  validates :phc, :presence => true
  belongs_to :subcenter
  validates :subcenter, :presence => true
  belongs_to :anm
  validates :anm, :presence => true
  belongs_to :asha
  has_many :visits, :dependent => :destroy
  has_many :appointments, :dependent => :destroy
  has_many :sms

  validates :name, :presence => true
  # No validation for husband name
  validates :mother_age, :presence => true, :numericality => true
  validates :village, :presence => true
  validates :mobile, :numericality => true, :if => Proc.new { |p| !p.mobile.blank? }
  validates_length_of :mobile, :is => 10 , :message => "should be 10 digits", :if => Proc.new { |p| !p.mobile.blank? }
  validates :cell_access, :presence => true
  enumerate :cell_access do
    value :name => 'yes'
    value :name => 'no'
  end
  validates :taayi_card_number, :numericality => true, :if => Proc.new{ |p| !p.taayi_card_number.blank? }
  validates_length_of :taayi_card_number, :is => 7, :if => Proc.new{ |p| !p.taayi_card_number.blank? }
  validates_uniqueness_of :encrypted_taayi_card_number, :if => Proc.new{ |p| !p.taayi_card_number.blank? }
  validates :ec_number, :presence => true, :numericality => true, :length => { :within => 2..3 }
  validates :expected_delivery_date, :presence => true, :format => { :with => /\A\d\d\-\d\d\-\d\d\d\d\Z/, :message => "Expected delivery date must be of the form DD-MM-YYYY" }
  validates :caste, :presence => true
  enumerate :caste do
    value :name => 'SC'
    value :name => 'ST'
    value :name => 'Other'
  end
  enumerate :education do
    value :name => 'Illiterate'
    value :name => 'Literate'
    value :name => 'Primary Education'
    value :name => 'High School'
    value :name => 'Degree'
    value :name => 'Other'
  end
  validates :delivery_place, :presence => true
  enumerate :delivery_place do
    value :name => 'PHC'
    value :name => 'CHC'
    value :name => 'Taluk Hospital'
    value :name => 'District Hospital'
    value :name => 'Private Hospital'
    value :name => 'Other'
  end

  # Note: attr_encrypted _must_ go after enumerate (active_enum) in order to
  # work.
  attr_encrypted :husband_name, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :mother_age, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :village, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :mobile, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :cell_access, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :taayi_card_number, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :ec_number, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :expected_delivery_date, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :caste, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :education, :key => APP_CONFIG['encrypt_key']
  attr_encrypted :delivery_place, :key => APP_CONFIG['encrypt_key']

  before_create :randomize_receiving_texts
  after_create :generate_appointments

  def self.search(phc, query)
    where('phc_id = ? AND name LIKE ?', phc, "%#{query}%")
  end

  def self.creation_stats_by_week(phc_id)
    select("COUNT(1) as count, YEARWEEK(created_at, 1) as yrwk, YEAR(created_at) as year, WEEK(created_at, 1) as week")
      .where('phc_id = ?', phc_id)
      .group("yrwk")
      .order("yrwk DESC")
  end

  def checked_in?
    latest_visit && latest_visit.date == Date.today
  end

  def latest_visit
    Visit.where("patient_id = ?", self).order("date DESC").first
  end

  def scheduled_appointments
    if latest_visit
      Appointment.where("patient_id = ? AND date > ?", self, latest_visit.date).order("date ASC")
    else
      appointments
    end
  end

  def next_appointment
    scheduled_appointments.first if not scheduled_appointments.nil?
  end

  def appointment_today?
    appointments.select {|a| a.date == Date.today }.any?
  end

  def sent_sms_today?
    sms.select{ |sms| sms.date == Date.today }.any?
  end

  private

  # Randomly put this patient into control or experimental group
  def randomize_receiving_texts
    self.receiving_texts = (rand(2) == 1)
    return true # Apparently things break if this method doesn't return true
  end

  # Array of [appointment_type_id, time interval from expected delivery date]
  AUTO_APPOINTMENTS = [[1, -6.months], [2, -3.months], [3, -1.month], [4, 0.days], [5, 6.weeks], [6, 10.weeks], [7, 14.weeks], [8, 10.months]]
  def generate_appointments
    AUTO_APPOINTMENTS.each do |a|
      date = Date.parse(expected_delivery_date) + a[1]
      if date > Date.today
        appointments.create!(:date => date, :appointment_type_id => a[0])
      end
    end
  end
end

# == Schema Information
#
# Table name: patients
#
#  id                               :integer(4)      not null, primary key
#  name                             :string(255)
#  encrypted_mobile                 :string(255)
#  encrypted_cell_access            :string(255)
#  phc_id                           :integer(4)
#  created_at                       :datetime
#  updated_at                       :datetime
#  receiving_texts                  :boolean(1)
#  encrypted_expected_delivery_date :string(255)
#  encrypted_husband_name           :string(255)
#  encrypted_caste                  :string(255)
#  encrypted_taayi_card_number      :string(255)
#  encrypted_mother_age             :string(255)
#  encrypted_education              :string(255)
#  encrypted_delivery_place         :string(255)
#  anm_id                           :integer(4)
#  encrypted_ec_number              :string(255)
#  encrypted_village                :string(255)
#  subcenter_id                     :integer(4)
#  asha_id                          :integer(4)
#

