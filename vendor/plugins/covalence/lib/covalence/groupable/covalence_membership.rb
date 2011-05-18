module Covalence
  module Membership
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval do
        include Covalence::Relationship
        belongs_to :child, :polymorphic => true
        belongs_to :parent, :polymorphic => true
      end
    end
  end
  
  def role
    status.to_sym
  end
  
  def role=(role)
    status = role
  end
  
  module ClassMethods
    def generate_token
      Digest::SHA1.hexdigest("--#{Time.now.utc.to_s}--")
    end
  end

end
