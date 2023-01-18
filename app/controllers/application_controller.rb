require 'uri'
require 'net/http'
require 'csv'

class ApplicationController < ActionController::Base

  def home
  end
  
  def export
    #Using Net::HTTP method to fetch API data.
    uri = URI('https://api.teamtailor.com/v1/candidates')
    res = Net::HTTP.get_response(uri, {
      'Authorization' => 'Token token=' + ENV["TEAMTAILOR_API_KEY"], 
      'X-Api-Version' => '20210218'
    })
    
    #Using JSON.parse and mapping function to get an array of arrays with only specific data from response body.
    @csv_rows = JSON.parse(res.body)["data"].map { |candidate|
      job_application = URI(candidate["relationships"]["job-applications"]["links"]["related"])
      job_application_response = Net::HTTP.get_response(job_application, {
        'Authorization' => 'Token token=' + ENV["TEAMTAILOR_API_KEY"], 
        'X-Api-Version' => '20210218'
      })
      [ candidate["id"], 
        candidate["attributes"]["first-name"], 
        candidate["attributes"]["last-name"],
        candidate["attributes"]["email"],
        JSON.parse(job_application_response.body)["data"][0]["id"],
        JSON.parse(job_application_response.body)["data"][0]["attributes"]["created-at"]
      ]
     }
      
     headers = ['ID', 'First name', 'Last name', 'Email', 'Job application ID', 'Job application created at']
     
     #Using CSV.generate to generate csv file with candidate's data.
     csv_data = CSV.generate do |csv|
       csv << headers
       
       @csv_rows.each do |column|
         csv << column
       end
     end
     
     #Downloading csv file.
     send_data csv_data, filename: "candidates.csv"
  end
end
