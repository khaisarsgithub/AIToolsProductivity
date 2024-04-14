Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  get 'code_generator/new'
  post 'code_generator/generate'
  root 'code_generator#new'
end
