Rails.application.routes.draw do
  root 'application#home'
  get '/export', to: 'application#export'
end
