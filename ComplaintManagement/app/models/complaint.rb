class Complaint < ApplicationRecord
  belongs_to :user
  validates_presence_of :user


  def processing?
    status == "Processing"
  end

  def pending?
    status == "Pending"
  end

  def complete?
    status == "Complete"
  end

end
