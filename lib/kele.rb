require "kele/version"
require "httparty"

module Kele
  include HTTParty
  # Your code goes here...
  def initialize(email, password)
    @auth = { username: email, password: password }
  end

end
