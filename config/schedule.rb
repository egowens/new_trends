#Change path to play nice with rvm
job_type :runner, "cd #{path} && RAILS_ENV=development /Users/eric/.rvm/wrappers/ruby-2.0.0-p576@shopify/bundle exec rails runner ':task' :output"

#Run the Live Collection update
every 1.hours do
  runner "LiveCollection.update"
end
