require 'httparty'
require 'nokogiri'
require 'octokit'

# Scrape blog posts from the website

url = "https://mrcis.me/blog"
response = HTTParty.get(url)
parsed_page = Nokogiri::HTML(response.body)
posts = parsed_page.css('.py-1')

# Generate the updated blog posts list (top 5)
posts_list = ["\n### Recent Blog Posts\n\n"]
posts.first(5).each do |post|
  title = post.css('px-1.hover:scale-75.text-2xl.font-light.text-gray-900.dark:text-black').text.strip
  link = "https://www.mrcis.me#{post.at_css('a')[:href]}"
  posts_list << "* [#{title}](#{link})"
end

# Update the README.md file
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
repo = ENV['GITHUB_REPOSITORY']
readme = client.readme(repo)
readme_content = Base64.decode64(readme[:content]).force_encoding('UTF-8')

# Replace the existing blog posts section
posts_regex = /### Recent Blog Posts\n\n[\s\S]*?(?=<\/td>)/m
updated_content = readme_content.sub(posts_regex, "#{posts_list.join("\n")}\n")

client.update_contents(repo, 'README.md', 'Update recent blog posts', readme[:sha], updated_content)