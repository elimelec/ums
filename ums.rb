#!/usr/bin/env ruby

require 'nokogiri'
require 'mechanize'
require 'open-uri'

begin
  require './ums-config'
rescue LoadError
  File.open('ums-config.rb', 'w') do |file|
    file.puts 'USERNAME = ""'
    file.puts 'PASSWORD = ""'
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

#get values; years
options = agent.page.parser.css("select option")
options = options.map {|option| option.attribute("value").value}
options = options.select {|o| o.to_i > 10}

links = agent.page.links.select {|link| link.href[/vizualizare_situatie_detaliata_evaluari/]}

links.each do |link|
  page = agent.get(link.href)
  parser = page.parser

  title = parser.css("td.title_1").first
  title = title.content.strip

  nota = parser.css(".tabel_info td.celula_tabel_center").last
  next unless nota
  nota = nota.content.strip

  puts "#{title}: #{nota}"
end

