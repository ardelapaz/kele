require 'httparty'
require 'json'

module Roadmap
    include HTTParty
    base_url = "https://www.bloc.io/api/v1/"

    def get_roadmap(roadmap_id)
        # Chain ID is 7025
        response = self.class.get(api_url("roadmaps/#{roadmap_id}"), headers: { "authorization" => @auth_token })
        @roadmap = JSON.parse(response.body)
    end

    def get_checkpoint(checkpoint_id)
        response = self.class.get(api_url("checkpoints/#{checkpoint_id}"), headers: { "authorization" => @auth_token })
        @checkpoint = JSON.parse(response.body)
    end

    


    private
        def api_url(endpoint)
            "https://www.bloc.io/api/v1/#{endpoint}"
        end
end