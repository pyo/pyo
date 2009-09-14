class String
	
  def possesive
    if self.last=='s'
      "#{self}'"
    else
      #self.gsub(/(.*)([a-z]$)/i,'\1\'\2')
      "#{self}'s"
    end
  end

	def add_slashes
		self.gsub(/('|"|\0)/, "\\\\\\1")
	end

end