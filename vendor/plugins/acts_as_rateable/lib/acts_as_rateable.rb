module ActiveRecord
  module Acts
    module Rateable
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        # FIXME - rather than the with_scope/opts hacks, do something smarter in the association
        def acts_as_rateable(options = {})
          options = {:max_rating => 5}.merge(options)
          has_many :ratings, :as => :rateable, :dependent => :destroy do
            define_method(:options) { options }
            
            def categories
              options[:categories]
            end
            
            def max_rating
              options[:max_rating]
            end
          end
          include ActiveRecord::Acts::Rateable::InstanceMethods
        end
      end
            
      module InstanceMethods
        # Rates the object by a given score. A user id should be passed to the method.
        def rate_it(score, user_id, opts = {})
          scope_to_category(opts[:category]) do
            returning(ratings.find_or_initialize_by_user_id(user_id)) do |rating|
              rating.update_attributes!(:score => score, :category => opts[:category])
            end
          end
        end
        
        # Calculates the average rating. Calculation based on the already given scores.
        def average_rating(opts = {})
          scope_to_category(opts[:category]) do
            avg = ratings.average(:score)
            avg || 0.0
          end
        end

        # Rounds the average rating value.
        def average_rating_round(opts = {})
          average_rating(opts).round
        end
    
        # Returns the average rating in percent.
        def average_rating_percent(opts = {})
          f = 100 / ratings.max_rating.to_f
          average_rating(opts) * f
        end
        
        # Checks whether a user rated the object or not.
        def rated_by?(user_id, opts = {})
          scope_to_category(opts[:category]) do
            ratings.exists?(:user_id => user_id)
          end
        end

        # Returns the rating a specific user has given the object.
        def rating_by(user_id, opts = {})
          scope_to_category(opts[:category]) do
            rating = ratings.find_by_user_id(user_id)
            rating ? rating.score : nil
          end
        end
      
      private
      
        # FIXME - this entire category scoping thing could be better
        def scope_to_category(category)
          yield if category.blank?
          Rating.send(:with_scope, :find => {:conditions => {:category => category}}) do
            yield
          end
        end
        
      end # InstanceMethods
      
    end
  end
end
