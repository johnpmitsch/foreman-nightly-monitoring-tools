#!/usr/bin/env ruby

require 'net/http'    
require 'json'
require 'date'

KATELLO_TEAMS = ["Team Justin", "Team Jonathon", "Team Eric"]
FOREMAN_TEAMS = ["Team Adam", "Team Tomer", "Team Avi"]
DATE_FORMAT = "%m/%d/%Y"

def get_team_members(teams, team_name)
  team = teams.select { |t| t[:name].include? team_name }.first
  team[:members]
end

def get_full_team_list(team_names, all_teams)
  sub_team = []
  team_names.each do |team_name|
    sub_team << get_team_members(all_teams, team_name)
  end
  sub_team.flatten.shuffle
end

def next_sunday(date)
  next_sunday = date
  next_sunday = next_sunday.next_day while !next_sunday.sunday?
  next_sunday
end

def weekly_calendar(years=1) 
  today = Date.today
  tracker = next_sunday(today)
  next_year = tracker.next_year(years)
  weeks = []

  while tracker < next_year
    start_of_week = tracker
    end_of_week = tracker.next_day(6)
    weeks << "#{start_of_week.strftime(DATE_FORMAT)} - #{end_of_week.strftime(DATE_FORMAT)}" 
    tracker = next_sunday(end_of_week)
  end

  weeks
end

#### MAIN ####

uri = URI(ENV["OHSNAP_URL"])
req = Net::HTTP::Get.new(uri)
res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
teams = JSON.parse(res.body, symbolize_names: true)

katello = get_full_team_list(KATELLO_TEAMS, teams)
foreman = get_full_team_list(FOREMAN_TEAMS, teams)

puts foreman
puts katello
puts foreman.length
puts katello.length
weekly_calendar.each_with_index do |week, i|
  katello_rep = katello[i % katello.length - 1]
  foreman_rep = foreman[i % foreman.length - 1]
  puts "#{week}: #{katello_rep[:name]} #{foreman_rep[:name]}"
end

