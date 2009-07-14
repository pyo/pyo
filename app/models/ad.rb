class Ad < Event
	
	DURATION = 30.days
	
	before_validation :set_start_and_end_dates, :if => :needs_dates?
	
	def set_start_date
		self.start_date = created_at_or_now
	end
	
	def set_end_date
		self.end_date = created_at_or_now + DURATION
	end
	
	protected
	
	def created_at_or_now
		(self.created_at || Time.now)
	end
	
	def needs_dates?
		new_record? || start_date.nil? || end_date.nil?
	end
	
	def	set_start_and_end_dates
		self.set_start_date
		self.set_end_date
		true
	end
	
end
