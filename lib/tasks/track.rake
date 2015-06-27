namespace :track do
  desc 'Mark all READY tracks as PUBLIC'
  task :ready2public => :environment do
    Track.where(status: 'READY').update_all(status: 'PUBLIC')
  end
end
