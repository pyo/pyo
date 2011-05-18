namespace :count_von_count do
  
  desc "Sync View Counts"
  task :sync => :environment do
    results = CountVonCount::View.connection.select_all("select model_type, model_id, count(*) as counter from count_von_count_views group by model_type, model_id")
    results.each do |result|
      model = result['model_type'].constantize
      model.update_counters(result['model_id'], :total_view_count => result['counter'].to_i) if model.column_names.include?('total_view_count')
    end
  end
end

namespace :cvc do
  desc "Synv View Counts"
  task :sync    => "count_von_count:sync"
end
