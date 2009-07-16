namespace :beanstalkd do
  task :start do
    fork do
      %x{beanstalkd -p 11300}
    end
    fork do
      %x{vendor/plugins/async_observer/bin/worker}
    end
  end
end