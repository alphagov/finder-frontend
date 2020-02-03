desc "Unpublish business finder results and questions pages"
task :unpublish_business_finder => :environment do |_, args|
  content_ids = %w[b9ef4434-761f-49ae-af97-dc7a248499c4 42ce66de-04f3-4192-bf31-8394538e0734]
  content_ids.each do |content_id|
    Services.publishing_api.unpublish(content_id, type: "redirect", alternative_path: "/transition")
  end
end

desc "Unpublish prepare eu exit campaign page"
task :unpublish_brexit_campaign_page => :environment do |_, args|
  content_ids = %w[ecb55f9d-0823-43bd-a116-dbfab2b76ef9]
  content_ids.each do |content_id|
    Services.publishing_api.unpublish(content_id, type: "redirect", alternative_path: "/transition")
  end
end
