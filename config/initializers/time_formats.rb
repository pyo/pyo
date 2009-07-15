Time::DATE_FORMATS[:human_date] = lambda { |time| time.strftime("%A %B #{time.day.ordinalize} #{time.year unless time.year==Time.now.year}") }
Time::DATE_FORMATS[:human_time] = lambda { |time| time.strftime("%I").gsub(/^0/,'') << time.strftime(":%M %p") }
Time::DATE_FORMATS[:human_date_and_time] = lambda { |time| time.strftime("%A %B #{time.day.ordinalize} #{time.year unless time.year==Time.now.year} at #{time.to_formatted_s(:human_time)}") }