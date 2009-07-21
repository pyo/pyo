class Tagging
	
	before_create :reset_tag_count
	
	protected
	def reset_tag_count
		unless self.tag.nil?
			if tag.current?
				tag.update_attribute :search_count, (tag.search_count + 1)
			else
				tag.update_attribute :search_count, 0
			end
		end
	end
end

class Tag
	
	# Tag#current only retrieves tags that belong to an Ad or Event that is not past its end date
	named_scope :current,
		:conditions=>["events.end_date >= NOW()"], 
		:joins=>"JOIN taggings ON taggings.tag_id = tags.id JOIN events ON taggings.taggable_id = events.id AND taggings.taggable_type = 'Event'"
	
	named_scope :most_popular, :order=>"search_count DESC"
	named_scope :least_popular, :order=>"search_count ASC"
	
	def self.up_mod_tags tag_names
		tags = tag_names.collect{|tag|tag.is_a?(Tag) ? tag : Tag.find_by_name(tag)}.compact
		
		tags.collect(&:up_mod)
	end
	
	def current?
		Tag.current.count(:conditions=>{:id=>self.id}) > 0
	end
	
	def up_mod
		update_attribute :search_count, (search_count + 1)
	end
end