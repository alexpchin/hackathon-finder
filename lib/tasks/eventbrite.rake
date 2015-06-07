require 'httparty'

class Eventbrite
  include HTTParty
  TOKEN = ENV['EVENTBRITE_OAUTH']

  def initialize()
    @base_uri = "https://www.eventbriteapi.com/v3/events/search/?token=#{TOKEN}"
  end

  def search(query, city, page)
    @options = { query: 
      { 
        "q"          => query, 
        "venue.city" => city, 
        "page"       => page
      }
    }
    self.class.get(@base_uri, @options)
  end

  def save(query, city, page)
    response   = search(query, city, page)
    page_count = response["pagination"]["page_count"]
    puts "#{page_count} pages found..."

    while page_count > 0 do
      (1..page_count).each do |page|
        response['events'].map do |event|
          db_event = Event.find_by_provider_and_external_id(self.class.name, event["id"])
          if !db_event
            Event.create!({
              provider: self.class.name,
              external_id: event["id"],
              content:  event.to_json
            })
            puts "Added event #{event["name"]["text"]} to the database"
          else
            db_event.update_attributes({
              provider: self.class.name,
              external_id: event["id"],
              content:  event.to_json
            })
            puts "#{event["name"]["text"]} updated"
          end      
        end

        page_count -= 1
        response = search(query, city, page+=1)
      end
    end
  end
  
end

namespace :search do
  desc "Querying Eventbrite API"
  task :eventbrite => :environment do
    Eventbrite.new().save("hackathons", "London", 1)
  end
end