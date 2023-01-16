require 'dotenv'
require 'httparty'

class Candidates
  include HTTParty
  
  def teamtailor_candidates
    self.class.get("https://api.teamtailor.com/v1/candidates?api_key=UN2d6SNd0RoesuGxxAKFVin9UPnNHEAmfhejdZa5")
  end
end

candidates = Candidates.new
puts candidates.teamtailor_candidates