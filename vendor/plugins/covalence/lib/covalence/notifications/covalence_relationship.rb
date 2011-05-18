module Covalence
  module Relationship
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval do
        belongs_to  :parent, :polymorphic => true
        belongs_to  :child, :polymorphic => true

        validates_presence_of :parent
        validates_presence_of :child
      end
    end
  
    module ClassMethods
    
      def find_by_parent_and_child(parent, child)
        first(:conditions => [
          'parent_type = ? and parent_id =? and child_type = ? and child_id = ?',
          parent.class.to_s, 
          parent.id, 
          child.class.to_s, 
          child.id
        ])
      end
    end
  end
    
end