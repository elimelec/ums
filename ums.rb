#!/usr/bin/env ruby

%w(nokogiri mechanize).each do |gem|
  begin
    require gem
  rescue LoadError
    puts "#{gem} not installed"
    puts "    `gem install #{gem}`"
    exit
  end
end

require 'open-uri'

begin
  require './ums-config'
rescue LoadError
  File.open('ums-config.rb', 'w') do |file|
    file.puts 'USERNAME = ""'
    file.puts 'PASSWORD = ""'
    file.puts
  end
  puts '"ums-config.rb" config file created'
  exit
end

agent = Mechanize.new
agent.get("https://ums.ulbsibiu.ro/ums/do/secure/inregistrare_user")
agent.page.forms[0]["j_username"] = USERNAME
agent.page.forms[0]["j_password"] = PASSWORD
agent.page.forms[0].submit

# change context
agent.page.links.find {|link| link.text[/context/]}.click
agent.page.links.find {|link| link.text[/Calculatoare/]}.click

# note
agent.page.links.find {|link| link.text[/Note/]}.click

links = agent.page.links.select {|link| link.href[/vizualizare_situatie_detaliata_evaluari/]}

links.each do |link|
  page = agent.get(link.href)
  parser = page.parser

  title = parser.css("td.title_1").first
  title = title.content.strip
  title = title.split(' - ').last

  nota = parser.css(".tabel_info td.celula_tabel_center").last
  next unless nota
  nota = nota.content.strip

  puts "#{title}: #{nota}"
end

