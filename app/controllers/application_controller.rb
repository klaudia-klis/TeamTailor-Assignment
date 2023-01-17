require 'uri'
require 'net/http'
require 'csv'

class ApplicationController < ActionController::Base

  def home
  
  uri = URI('https://api.teamtailor.com/v1/candidates')
  res = Net::HTTP.get_response(uri, {
    'Authorization' => 'Token token=UN2d6SNd0RoesuGxxAKFVin9UPnNHEAmfhejdZa5', 
    'X-Api-Version' => '20210218'
  })
  
  @csv_rows = JSON.parse(res.body)["data"].map { |candidate|
    job_application = URI(candidate["relationships"]["job-applications"]["links"]["related"])
    job_application_response = Net::HTTP.get_response(job_application, {
      'Authorization' => 'Token token=UN2d6SNd0RoesuGxxAKFVin9UPnNHEAmfhejdZa5', 
      'X-Api-Version' => '20210218'
    })
    puts job_application_response.body
    [ candidate["id"], 
      candidate["attributes"]["first-name"], 
      candidate["attributes"]["last-name"],
      candidate["attributes"]["email"],
      JSON.parse(job_application_response.body)["data"][0]["id"],
      JSON.parse(job_application_response.body)["data"][0]["attributes"]["created-at"]
    ]
   }
   
    def csv_tool headers, data  
      headers = ['ID', 'First name', 'Last name', 'Email', 'Job application ID', 'Job application created at']
      
      CSV.open('public/export.csv', 'wb') do |csv|
        csv << headers
        
        data.each do |column|
          csv << column
        end
      end
    end
    csv_tool headers, @csv_rows
  end
end
