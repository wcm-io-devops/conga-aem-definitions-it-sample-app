title "Sling Mapping"

page_urls_with_mapping = [
  "#{input('tenant1_url')}/en.html",
  "#{input('tenant1_url')}/en/page-1.html",
  "#{input('tenant1_url')}/en/page-2.html",
  "#{input('tenant1_url')}/de.html",
  "#{input('tenant1_url')}/de/page-1.html",
  "#{input('tenant1_url')}/de/page-2.html",
  "#{input('tenant2_url')}/en.html",
  "#{input('tenant2_url')}/en/page-1.html",
  "#{input('tenant2_url')}/en/page-2.html"
]

page_urls_without_mapping = [
  "#{input('tenant3_url')}/content/aemdef-it-sample/tenant3-no-mapping/en.html",
  "#{input('tenant3_url')}/content/aemdef-it-sample/tenant3-no-mapping/en/page-1.html",
  "#{input('tenant3_url')}/content/aemdef-it-sample/tenant3-no-mapping/en/page-2.html",
]

page_urls_with_mapping.each do |url|
  http_resp = http(url)

  describe http_resp do
    its('status') { should cmp 200 }
    its('body') { should_not be_empty }
  end

end

page_urls_without_mapping.each do |url|
  http_resp = http(url)

  describe http_resp do
    its('status') { should cmp 200 }
    its('body') { should_not be_empty }
  end

end
