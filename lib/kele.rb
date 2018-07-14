require 'httparty'
require 'json'
require 'openssl'
require './lib/roadmap'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Kele
  include HTTParty
  include Roadmap
  base_uri "https://www.bloc.io/api/v1/"

  def initialize(email, password)
    response = self.class.post(api_url("sessions"), body: { email: email, password: password })
    raise 'Invalid email or password, please try again.' if response.code == 401
    @auth_token = response["auth_token"]
    puts response.code
  end

  def get_me
    response = self.class.get(api_url("users/me"), headers: { "authorization" => @auth_token })
    @user = JSON.parse(response.body)
    @user_id = @user["current_enrollment"]
    # My user ID is 41521
  end

  def get_mentor_availability(mentor_id)
    # My mentor ID is 2366806
    response = self.class.get(api_url("mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token}).to_a
    availability = []
    response.each do |slot|
      if slot["booked"] == nil
        availability.push(slot)
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

  def get_remaining_checkpoints(chain_id)
    response = self.class.get(api_url("/enrollment_chains/#{chain_id}/checkpoints_remaining_in_section"), headers: { "authorization" => @auth_token })
    @remaining_checkpoints = JSON.parse(response.body)
  end

  private 

  def api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end
end
