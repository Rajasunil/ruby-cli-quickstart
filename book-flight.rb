require 'net/http'
require 'uri'
require 'json'
require 'time'

duffel_access_token = "[INSERT YOUR DUFFEL ACCESS TOKEN HERE]"

puts "Duffel Flights API - Ruby CLI Quickstart"

puts "\nWhere do you want to go?"
destination = gets.chomp.upcase

puts "\nFrom where?"
origin = gets.chomp.upcase

puts "\nOn what date? (YYYY-MM-DD)"
departure_date = gets.chomp

puts "\nSearching flights..."

uri = URI('https://api.duffel.com/air/offer_requests')
req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Duffel-Version' => 'beta', 'Authorization' => "Bearer #{duffel_access_token}")
req.body = {
  data: {
    passengers: [{type: "adult"}],
    slices: [{origin: origin, destination: destination, departure_date: departure_date}],
    cabin_class: "economy"
  }
}.to_json
res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http| http.request(req) end

search_data = JSON.parse(res.body)["data"]
offers = search_data["offers"]

offers.each_with_index { |o, index| puts "#{index+1}. #{o["owner"]["name"]} flight departing at #{Time.parse(o["slices"][0]["segments"][0]["departing_at"]).strftime("%H:%M")} #{o["total_amount"]} #{o["total_currency"]}" }

puts "\nWhich offer do you wish to book?"
offer_index = gets.chomp

puts "\nWhat's your given name?"
given_name = gets.chomp

puts "\nWhat's your family name?"
family_name = gets.chomp

puts "\nWhat's your date of birth? (YYYY-MM-DD)"
date_of_birth = gets.chomp

puts "\nWhat's your title? (mr, ms, mrs, miss)"
title = gets.chomp

puts "\nWhat's your gender? (m, f)"
gender = gets.chomp

puts "\nWhat's your phone number? (+XX)"
phone_number = gets.chomp

puts "\nWhat's your email address?"
email = gets.chomp

puts "\nHang tight! Booking offer #{offer_index}..."

selected_offer = offers[offer_index.to_i-1]

uri = URI('https://api.duffel.com/air/orders')
req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Duffel-Version' => 'beta', 'Authorization' => "Bearer #{duffel_access_token}")
req.body = {
  data: {
    payments: [{currency: selected_offer["total_currency"], amount: selected_offer["total_amount"], type: "balance"}],
    passengers: [{phone_number: phone_number, email: email, title: title, gender: gender, family_name: family_name, given_name: given_name, born_on: date_of_birth, id: search_data["passengers"][0]["id"]}],
    selected_offers: [selected_offer["id"]],
  }
}.to_json
res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http| http.request(req) end

order_data = JSON.parse(res.body)["data"]

puts "\n🎉 Flight booked. Congrats! You can start packing your (duffel?) bags"
puts "Booking reference: #{order_data["booking_reference"]}"
