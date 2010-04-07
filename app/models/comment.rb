class Comment < ActiveRecord::Base
  include Covalence::Notification
  
  ####################
  ### Associations ###
  ####################
  
  has_many :comments,   :as => 'consumer', :dependent => :destroy
  has_many :activities, :as => 'payload', :dependent => :destroy
  
  ###################
  ### Validations ###
  ###################
  
  validates_length_of :message, :maximum => 300
  
  ##############
  ### Scopes ###
  ##############
  
  default_scope :order => "created_at desc"

  ###############
  ### Methods ###
  ###############
  
  def after_create
		unless consumer.is_a?(Comment) || consumer.is_a?(Group)
	    CommentActivity.create({:producer => producer, :payload => self})
	    producer.followers.each do |follower|
	      CommentActivity.create({:producer => producer, :consumer => follower, :payload => self})
	    end
		end
    if consumer.respond_to?(:comments_count)
      consumer.class.increment_counter(:comments_count, consumer.id)
    end
  end
  
  def before_destroy
    if consumer.respond_to?(:comments_count)
      consumer.class.decrement_counter(:comments_count, consumer.id)
    end
  end
end
