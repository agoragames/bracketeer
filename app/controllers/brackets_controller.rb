class BracketsController < ApplicationController
  def index
    # LOLOLO BRACKET SETUP STUB
  end

  def export
    title = params[:title].parameterize
    json = JSON.parse(params[:bracket])
    send_data JSON.generate(json), type: 'application/vnd.bracket_tree',
      filename: "#{title}.json", status: 200
  end
end
