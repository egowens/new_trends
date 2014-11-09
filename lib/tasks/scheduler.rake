desc "Heroku scheduler task for updating Live Collections"
task :update_collections => :environment do
  puts "Updating collections..."
  Collection.update
  puts "done!"
end

task :update_live_collections => :environment do
  puts "Updating live collections..."
  LiveCollection.update
  puts "done!"
end
