Bracketeer::Application.routes.draw do
  resources :brackets

  root to: 'brackets#index'
end
