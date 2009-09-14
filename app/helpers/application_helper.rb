# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_owner? item
    current_user == case true
      when item.respond_to?(:user) then item.user
      when item.respond_to?(:producer) then item.producer
    end
  end
  
  def radio_for_rating val,checked
    attrs = {:class => "star"}
    attrs.merge(:disabled=>"disabled") unless current_user
    attrs.merge(:checked=>"true") if checked
    
    radio_button_tag("star1",val, checked,attrs)
  end

	def custom_error_messages form
		content_tag("h2", "There were some problems with your informaiton", :class=>"form_errors") if form.object.errors.count > 0
	end
  
  
  	def filter_html(html,profile='')
  		unless profile.class.to_s == 'Hash'
  			profile=get_profile
  		end
  		if html.index('<')
  			tokenizer = HTML::Tokenizer.new(html)
  			new_text=''
  			while token = tokenizer.next
  				node=HTML::Node.parse(nil, 0, 0, token, false)
  				if node.class.to_s == 'HTML::Tag' && profile[node.name]
  					allowed_attributes=filter_attributes(node,profile[node.name])
  					new_node=HTML::Tag.new(node.parent, node.line, node.position, node.name, allowed_attributes, node.closing)
  					new_text << new_node.to_s
  				else
  					new_text << node.to_s.gsub(/</,'&amp;LT;')
  				end
  			end
  			html = new_text
  		end
  		return html
  	end

  private

  	def get_profile 
  		return {
  		'strong'=>{'none'=>1},
  		'b' => {'none'=>1},
  		'ul' => {'none'=>1},
  		'li' => {'none'=>1},
  		'ol'=>{'none'=>1},
  		'i'=>{'none'=>1},
  		'u'=>{'none'=>1},
  		'code'=>{'none'=>1},
  		'pre'=>{'none'=>1},
  		'p'=>{'none'=>1},
  		'div'=>{'none'=>1},
  		'br'=>{'none'=>1},
  		'table'=>{'none'=>1},
  		'tr'=>{'none'=>1},
  		'td'=>{'none'=>1},
  		'th'=>{'none'=>1},
  		'tbody'=>{'none'=>1},
  		'thead'=>{'none'=>1},
  		'span'=>{'none'=>1},
  		'h1'=>{'none'=>1},
  		'h2'=>{'none'=>1},
  		'h3'=>{'none'=>1},
  		'h4'=>{'none'=>1},
  		'h5'=>{'none'=>1},
  		'h6'=>{'none'=>1},
  		'dl'=>{'none'=>1},
  		'dt'=>{'none'=>1}
  	}
  	end

  	def filter_attributes(node,allowed_attributes)
  		safe_attributes={}
  		if allowed_attributes['none'] == 1
  			#No attributes are safe. Strip 'em all.
  			return safe_attributes
  		elsif allowed_attributes['any'] == 1
  			#We'll allow all attributes with all values. DANGER WILL ROBINSON!
  			safe_attributes=node.attributes
  			return safe_attributes
  		end
  		if node.attributes
  			#If a node doesn't have attributes, don't bother inspecting them.	
  			for attribute in node.attributes.keys
  				if allowed_attributes[attribute].class.to_s == 'Array'
  					if allowed_attributes[attribute].include?('any')
  						#We'll allow all values for this attribute.
  						safe_attributes[attribute] = node.attributes[attribute]	
  					elsif allowed_attributes[attribute].include?(node.attributes[attribute])
  						#We're only allowing a subset of attributes.
  						safe_attributes[attribute] = node.attributes[attribute]
  					end
  				end
  			end
  		end
  		return safe_attributes
  	end
end
