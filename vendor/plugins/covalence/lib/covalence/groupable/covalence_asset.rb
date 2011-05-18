module Covalence
  module Asset
    def self.included(model)
      model.class_eval do
        belongs_to :assetable, :polymorphic => true
        belongs_to :groupable, :polymorphic => true
      end
    end
  end
end