require 'httparty'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Kele
  include HTTParty
  base_uri "https://www.bloc.io/api/v1/"

  def initialize(email, password)
    response = self.class.post(api_url("sessions"), body: { username: email, password: password })
    raise 'Invalid email or password, please try again.' if response.code == 401
    @auth_token = response["auth_token"]
    puts response.code
  end

  def get_me
    response = self.class.post(api_url("users/me"), headers: { "authorization" => @auth_token })
    @user = JSON.parse(response.body)
    @user_id = response["current_enrollment"]["id"]
  end

  def get_mentor_availability(mentor_id)
    response = self.class.post(api_url("mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token})
    availability = []
    response.each do |response|
      if response["booked"] == nil
        availability.push(response)
      end
    end
    puts availability
  end

  def get_messages(page = 0)
    if page > 0
      messages_endpoint = "/message_threads?page=#{page}"
    else
      messages_endpoint = "/message_threads"
    end
    response = self.class.get(api_url(messages_endpoint), headers: { "authorization" => @auth_token })
    @messages = JSON.parse(response.body)
  end

  def create_message(sender, recipient_id, subject, stripped_text, token = nil)
    response = self.class.post("/messages", headers: { "authorization" => @auth_token }, body: {
      sender: sender,
      recipient_id: recipient_id, 
      token: token, 
      subject: subject,
      stripped_text: stripped_text
    })
    response.success? puts "Your message has been sent!"
  end

  def get_remaining_checkpoints()
    response = self.class.get(api_url("#{@user_id}/checkpoints_remaining_in_section"), headers: { "authorization" => @auth_token})
    @remaining_checkpoints = JSON.parse(response.body)
  end

  private 

  def api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end
end
