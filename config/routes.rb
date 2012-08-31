Bracketeer::Application.routes.draw do
  #resources :brackets
  post 'export', to: 'brackets#export'

  root to: 'brackets#index'
end
