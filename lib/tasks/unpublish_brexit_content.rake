desc "Unpublish and redirect a piece of content"
task :unpublish_content, %i[content_item_id parameters] => :environment do |_, args|
  id = args[:content_item_id]
  params = args[:parameters]
  puts "Calling unpublish for content id: #{id}"
  puts "with the following params:"
  params.each { |k, v| puts "#{k}: #{v}" }
  response = Services.publishing_api.unpublish(id, params)
  puts "Done" if response.code == 200
  puts "Error" if !response.code == 200
end
