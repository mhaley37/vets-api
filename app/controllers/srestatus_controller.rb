require 'faraday'
require 'json'

class SrestatusController < ApplicationController
    before_action :authenticate, only: [:welcome]
    def index
      url = 'https://icanhazdadjoke.com/'
      response = Faraday.get(url, {a: 1}, {'Accept' => 'application/json'})
      joke_object = JSON.parse(response.body, symbolize_names: true)
      puts joke_object
      render json: { services: [ 'srv01': { 'status': 'ok', 'msg': joke_object }, 'srv02': { 'status': 'failed', 'msg': 'Down For Repair' } ],
        incidents: [ 'srv02-20220406120000': { 'type': 'network', 'msg': 'TIC Error' } ]}
    end
end
