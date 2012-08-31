class BracketsController < ApplicationController
  def index
    # LOLOLO BRACKET SETUP STUB
  end

  def export
    json = JSON.parse(params[:bracket])
    send_data json, type: 'application/vnd.bracket_tree',
      filename: 'bracket_tree.json', status: 200
  end
end
