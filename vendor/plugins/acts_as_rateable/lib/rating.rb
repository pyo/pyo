class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  validates_presence_of :score
  validates_uniqueness_of :user_id, :scope => [:rateable_id, :rateable_type, :category]
  validate :max_rating_allowed_by_parent
  validate :in_category_allowed_by_parent
  
private
  
  def max_rating_allowed_by_parent
    if score < 1
      errors.add(:score, "must be greater than or equal to 1")
    elsif score > max_rating
      errors.add(:score, "must be less than or equal to #{max_rating}")
    end
  end

  def rateable_options
    rateable.ratings.options
  end
  
  def max_rating
    rateable_options[:max_rating]
  end
  
  def categories
    rateable_options[:categories]
  end
  
  def in_category_allowed_by_parent
    return if categories.blank?
    unless categories.include?(category)
      errors.add(:category, "must be one of the following: #{categories.to_sentence(:connector => 'or')}")
    end
  end

end
