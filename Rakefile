require 'fileutils'

namespace :draft do
  desc "Creating a new draft for post/entry"
  task :new do
    puts "What's the name for your next post?"
    @name = STDIN.gets.chomp
    @slug = "#{@name}"
    @slug = @slug.tr('ÁáÉéÍíÓóÚú', 'AaEeIiOoUu')
    @slug = @slug.downcase.strip.gsub(' ', '-')
    current_date = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
    FileUtils.touch("_drafts/#{@slug}.md")
    open("_drafts/#{@slug}.md", 'a' ) do |file|
      file.puts "---"
      file.puts "title: #{@name}"
      file.puts "date: #{current_date}"
      file.puts "description: maximum 155 char description"
      file.puts "categories: [Hacking for Beginners]"
      file.puts "tags: [HTB, CTFs, Hacking]"
      file.puts "image:
    path:"
      file.puts "---"
      file.puts ""
      file.puts ""
      file.puts "- **[The Best Academy to Learn Hacking](https://affiliate.hackthebox.com/nenandjabhata)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**."
    file.puts ""
    file.puts ""
    file.puts "## Reconnaissance"
    file.puts ""
    file.puts ""
    file.puts "## Privilege Escalation"
    file.puts ""
    file.puts ""
    file.puts "## Ressources supplementaires"
    file.puts "Voici quelques ressources supplémentaires qui pourraient vous être utiles :"
    file.puts "[]()"
    file.puts "[]()"
    file.puts "- [Join Us on Discord](https://discord.gg/wBT9wr9ruG)."
    end
  end

  desc "copy draft to production post!"
  task :ready do
    puts "Posts in _drafts:"
    Dir.foreach("_drafts") do |fname|
      next if fname == '.' or fname == '..' or fname == '.keep'
      puts fname
    end
    puts "what's the name of the draft to post?"
    @post_name = STDIN.gets.chomp
    @post_date = Time.now.strftime("%F")
    FileUtils.mv("_drafts/#{@post_name}", "_posts/#{@post_name}")
    FileUtils.mv("_posts/#{@post_name}", "_posts/#{@post_date}-#{@post_name}")
    puts "Post copied and ready to deploy!"
  end
end