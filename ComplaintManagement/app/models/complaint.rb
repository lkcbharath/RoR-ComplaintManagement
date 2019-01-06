class Complaint < ApplicationRecord
  belongs_to :user
  validates_presence_of :user

  validates :title, presence: true

  def processing?
    status == "Processing"
  end

  def pending?
    status == "Pending"
  end

  def complete?
    status == "Complete"
  end

  def new_status(current_user)
    new_status = status
    if current_user.try(:admin?)
      if pending?
        new_status = 'Processing'
      elsif processing?
        new_status = 'Complete'
      end
    elsif user_id == current_user.id && complete?
      new_status = 'Resolved'
    end
    return new_status
  end

end
