module ThinkingSphinxTestHelper
	
	def self.extended base
		#{}%x{rake ts:stop RAILS_ENV=test && rake ts:start RAILS_ENV=test}
	end
	
	def ts_index
		puts "\n\nThinking Sphinx:\nindexing test data...\n\n"
    ThinkingSphinx::Deltas::Job.cancel_thinking_sphinx_jobs
   
    config = ThinkingSphinx::Configuration.instance
    unless ENV["INDEX_ONLY"] == "true"
      puts "Generating Configuration to #{config.config_file}"
      config.build
    end
       
    FileUtils.mkdir_p config.searchd_file_path
    cmd = "#{config.bin_path}#{config.indexer_binary_name} --config \"#{config.config_file}\" --all"
    cmd << " --rotate" if ThinkingSphinx.sphinx_running?
   
    system! cmd
	end
	
	def ts_rebuild
		ts_stop if sphinx_running?
		ts_start
		ts_index
	end
	
	def ts_start
    config = ThinkingSphinx::Configuration.instance
    
    FileUtils.mkdir_p config.searchd_file_path
    raise RuntimeError, "searchd is already running." if sphinx_running?
    
    Dir["#{config.searchd_file_path}/*.spl"].each { |file| File.delete(file) }

    system! "#{config.bin_path}#{config.searchd_binary_name} --pidfile --config \"#{config.config_file}\""
    
    sleep(2)
    
    if sphinx_running?
      puts "Started successfully (pid #{sphinx_pid})."
    else
      puts "Failed to start searchd daemon. Check #{config.searchd_log_file}"
    end
	end
	
	def ts_stop
    raise RuntimeError, "searchd is not running." unless sphinx_running?
    config = ThinkingSphinx::Configuration.instance
    pid    = sphinx_pid
    system! "#{config.bin_path}#{config.searchd_binary_name} --stop --config \"#{config.config_file}\""
    puts "Stopped search daemon (pid #{pid})."
	end
	
	protected
	
	def sphinx_pid
  	ThinkingSphinx.sphinx_pid
	end

	def sphinx_running?
	  ThinkingSphinx.sphinx_running?
	end

	# a fail-fast, hopefully helpful version of system
	def system!(cmd)
	  unless system(cmd)
	    raise <<-SYSTEM_CALL_FAILED
	The following command failed:
	  #{cmd}

	This could be caused by a PATH issue in the environment of cron/passenger/etc. Your current PATH:
	  #{ENV['PATH']}
	You can set the path to your indexer and searchd binaries using the bin_path property in config/sphinx.yml:
	  production:
	    bin_path: '/usr/local/bin'
	SYSTEM_CALL_FAILED
	  end
	end

end
