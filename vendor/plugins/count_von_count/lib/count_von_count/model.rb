module CountVonCount
  module Model
    
    def update_view_count(request)
      unless CountVonCount.blacklist.include?(request.remote_ip)
        if (view = CountVonCount::View.find_or_initialize_by_model_type_and_model_id_and_ip_addr(self.class.name, self.id, request.remote_ip)).new_record?
          view.save
          self.increment!(:total_view_count) if self.respond_to?(:total_view_count)
          logger.info "THE COUNT SAYS: #{self.view_count} view counts ah ah ah" if CountVonCount.debug
        end
      end
    end
     
    def view_count(options = {})
      
      condition_strings = ["model_type = ? and model_id = ?"]
      condition_args = [self.class.name, self.id]
      
      if options.empty? and self.respond_to?(:total_view_count)
        return total_view_count
      end
      
      if options[:range]
        if options[:range].is_a?(String)
         options[:from], options[:to] = str_to_range(options[:range]) 
        end
      end
      
      if options[:from]
        condition_strings << "created_at > ?"
        condition_args << options[:from]
      end
      if options[:to]
        condition_strings << "created_at < ?"
        condition_args << options[:to]
      end
      
      CountVonCount::View.count(:conditions => [condition_strings.join(' and '), *condition_args])
      
    end
    
    def str_to_range(desc)
      now = Time.now.getgm
      words = desc.downcase.split(/\s+/)
      if words[0] == 'today'
        [Time.local(now.year, now.month, now.day).getgm, nil]
      elsif words[0] == 'yesterday'
        [Time.local(now.year, now.month, now.day - 1).getgm, Time.local(now.year, now.month, now.day - 1, 23, 59).getgm]
      else
        # not yet implemented
        [nil, now.getgm]
      end
    end
    
  end
end