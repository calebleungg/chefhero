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
  # checkout strip session
  get "/order/new/:id", to: "order#new", as: "new_order"

  # create order 
  post "/order/create", to: "order#create", as: "create_order"
  # order summary view
  get "/order/summary/:id", to: "order#summary", as: "order_summary"
  # order history view
  get "/order/history/:id", to: "order#history", as: "order_history"

  # main dashboard page
  get "/dashboard", to: "user#dashboard", as: "dashboard"
  
  # chefhero dashboard view
  get "/dashboard/manager", to: "user#manager", as: "manager"
  # delete a dish
  delete "/dish/:id/destroy", to: "dish#destroy", as: "delete_dish"
  # listing a dish
  patch "/dish/:id/list", to: "dish#list", as: "list_dish"
  # unlisting a dish
  patch "/dish/:id/unlist", to: "dish#unlist", as: "unlist_dish"
  # edit dish details view
  get "/dish/:id/edit", to: "dish#edit", as:"edit_dish"
  # updating dish details
  patch "/dish/:id/update", to: "dish#update", as: "update_dish"

  # update availability
  patch "/availability/update", to: "availability#update", as: "update_availability"
  # update address
  patch "/address/update", to: "address#update", as: "update_address"

  # become-chefhero form view
  get "/become-chefhero", to: "user#new_chef", as: "new_chef"
  # update member to chefhero account_type
  post "/become-chefhero", to: "user#create_chef", as: "create_chef"

  # ordres manager for chefhero
  get "/dashboard/orders", to: "order#manager", as: "orders_manager"
  # mark orders as ready
  patch "/order/:id/ready", to: "order#ready", as: "order_ready"
  # mark orders as collected
  patch "/order/:id/collected", to: "order#collected", as: "order_collected"
  # get chefhero order history
  get "/dashboard/orders/history", to: "order#chef_history", as: "dashboard_order_history"

  # earnings dashboard view
  get "/dashboard/earnings", to: "order#earnings", as: "earnings_manager"

  # post new withdrawal
  post "/user/:id/withdraw", to: "withdraw#create", as: "withdraw"

  # get index view for dishes
  get "/dishes", to: "dish#index", as: "dishes"
  # get index view for chefs
  get "/chefheroes", to: "user#chefs", as: "chefs" 

  # manager resources view
  get "/dashboard/resources", to: "user#resources", as: "resources"

  # new billing card view
  get "/card/new", to: "user#new_card", as: "add_payment_method"
  # creating enw billing card
  post "/card", to: "user#create_card", as: "create_payment_method"

  # create review request
  post "/review/create", to: "review#create", as: "create_review"

  # mark all notifications read
  patch "/notifications/clear", to: "notification#clear", as: "clear_notifications"

  scope "/checkout" do
    post "create", to: "checkout#create", as: "checkout_create"
    get "cancel", to: "checkout#cancel", as: "checkout_cancel"
    get "success", to: "checkout#success", as: "checkout_success"
  end

end
