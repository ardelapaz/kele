require "kele/version"
require "httparty"

module Kele
  include HTTParty
  
  base_uri "https://www.bloc.io/api/v1/"

  def initialize(email, password)
    response = self.class.post(api_url("sessions"), body: { username: email, password: password })
    raise 'Invalid email or password, please try again.' if response.code == 404
    @auth_token = response["auth token"]
    puts response
    puts @auth_token
  end

  def get_me
    response = self.class.post(api_url("users/me"), headers: { "authorization" => @auth_token })
    @user = JSON.parse(response.body)
    @user_id = response["current_enrollment"]["id"]
  end

end
