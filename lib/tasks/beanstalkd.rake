namespace :beanstalkd do
  task :start do
    `beanstalkd -d -p 11300  &`
    `vendor/plugins/async_observer/bin/worker`
  end
end