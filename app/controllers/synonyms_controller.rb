# coding: UTF-8
class SynonymsController < ApplicationController

  def destroy
    Synonym.find(params[:id]).destroy
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

end