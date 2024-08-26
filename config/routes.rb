Rails.application.routes.draw do
  root "activities#index"
  resources :activities do
    resources :static_maps, only: :show, param: :size,
                            constraints: { size: /\d+x\d+/ },
                            defaults: { size: "100x100", format: "png" }
  end

  namespace :admin do
    resources :users, except: [ :create ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
