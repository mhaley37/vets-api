class SrestatusController < ApplicationController
    before_action :authenticate, only: [:welcome]
    def index
      render json: { services: [ 'srv01': { 'status': 'ok', 'msg': 'none' }, 'srv02': { 'status': 'failed', 'msg': 'Down For Repair' } ],
       incidents: [ 'srv02-20220406120000': { 'type': 'network', 'msg': 'TIC Error' } ]}
    end
end
