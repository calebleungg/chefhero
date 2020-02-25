Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #home/splash page
  get "/", to: "user#index", as: "root"

  # user profile
  get "/profile/:name", to: "user#profile", as: "profile"
  # other member's profile
  get "/users/show/:id", to: "user#show", as: "user"
  # uploading new photo
  patch "/users/upload-photo", to: "user#upload_photo", as: "upload_photo"
  patch "/users/show/:id", to: "user#update_about", as: "update_about"

  # personal details page
  get "/profile/:name/details", to: "user#details", as: "details"

  # editing details view
  get "/profile/:name/edit", to: "user#edit", as: "edit_details"
  # updating details request
  patch "/profile/:name/edit", to: "user#update", as: "update_details"

  # new dish view
  get "/dish/new", to: "dish#new", as: "new_dish"
  # creating new dish
  post "/dish/new", to: "dish#create", as: "create_dish"

  # order dish modal view
  get "/dish/show/:id", to: "dish#show", as: "dish"
  # create order 
  post "/order/create", to: "order#create", as: "create_order"
  # order summary view
  get "/order/summary/:id", to: "order#summary", as: "order_summary"
  # order history view
  get "/order/history/:id", to: "order#history", as: "order_history"

  # chefhero dashboard view
  get "/dashboard/manager", to: "user#manager", as: "manager"
  # delete a dish
  delete "/dish/:id/destroy", to: "dish#destroy", as: "delete_dish"
  # listing a dish
  patch "/dish/:id/list", to: "dish#list", as: "list_dish"
  # unlisting a dish
  patch "/dish/:id/unlist", to: "dish#unlist", as: "unlist_dish"

  # update availability
  patch "/availability/update", to: "availability#update", as: "update_availability"
  # update address
  patch "/address/update", to: "address#update", as: "update_address"

end
