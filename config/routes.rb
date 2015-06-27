Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  root 'default#index'

  get 'news'     => 'notices#index', format: false
  get 'search'   => 'search#index', format: false
  get 'category' => 'category#index', format: false
  get 'history'  => 'search#history', format: false
  get 'latest'   => 'search#latest', format: false
  get 'chat'     => 'default#chat', format: false
  get 'faq'      => 'default#faq', format: false
  get 'speed'    => 'default#speed', format: false
  get 'support'  => 'default#support', format: false

  # TODO: RESTful
  get    'issues'      => 'issues#index', format: false
  get    'issues/new'  => 'issues#new', format: false
  post   'issues/new'  => 'issues#create', format: false
  get    'issues/:id'  => 'issues#show', format: false
  post   'issues/:id'  => 'issues#append', format: false
  put    'issues/:id'  => 'issues#update', format: false
  delete 'issues/:id'  => 'issues#destroy', format: false

  get 'listen'         => 'listen#redirect', as: 'listen'
  get 'robots.txt'     => 'static#robots', format: false, as: 'robots'
  get 'cache.appcache' => 'static#manifest', format: false, as: 'manifest'

  match 'preferences' => 'default#preferences', via: [:get, :patch], format: false

  get  'playlist' => 'json/playlist#index'
  post 'request'  => 'json/request#create'
  get  'status'   => 'json/status#index'

  resources :tracks, except: [:new, :create, :edit, :update, :destroy], format: false do
    resources :comments, controller: 'tracks/comments'
    resources :images, controller: 'tracks/images'
    resource  :lyrics, controller: 'tracks/lyrics'
  end

  resources :images, except: [:new, :create, :edit, :update, :destroy], format: false do
    resources :comments, controller: 'images/comments'
  end

  namespace :upload do
    get '' => '/upload#index', format: false

    resources :asin, except: [:create, :update], format: false do
      post  'new'  => 'asin#create', on: :collection, as: 'create'
      patch 'edit' => 'asin#update', on: :member,     as: 'update'
    end

    resources :niconico, param: :track_id, except: [:create, :update], format: false do
      patch 'new'  => 'niconico#fetch' , on: :collection, as: 'fetch'
      post  'new'  => 'niconico#create', on: :collection, as: 'create'
      patch 'edit' => 'niconico#update', on: :member,     as: 'update'
    end
  end

  namespace :admin do
    get  'notices' => 'notices#index', format: false
    post 'notices' => 'notices#update', format: false

    resources :images, except: [:create, :update], format: false do
      post 'edit'   => 'images#image_', on: :collection
      get  'export' => 'images#export', on: :collection, format: false
      post 'import' => 'images#import', on: :collection, format: false
    end

    resources :playlist, except: [:create, :update], format: false do
      post  'new'  => 'playlist#create', on: :collection, as: 'create'
      patch 'edit' => 'playlist#update', on: :member,     as: 'update'
    end

    resources :tracks, except: [:create, :update], format: false do
      post  'new'    => 'tracks#create', on: :collection, as: 'create'
      patch 'edit'   => 'tracks#update', on: :member,     as: 'update'
      get   'review' => 'tracks#review', on: :member
      patch 'review' => 'tracks#confirm', on: :member
    end

    resources :track_migrations, except: [:create, :update], format: false do
      post  'new'     => 'track_migrations#create', on: :collection, as: 'create'
      patch 'edit'    => 'track_migrations#update', on: :member,     as: 'update'
      get   'migrate' => 'track_migrations#migrate', on: :member
      post  'migrate' => 'track_migrations#transfer', on: :member
    end
  end

  get  'login'  => 'members#index', format: false
  post 'login'  => 'members#login', format: false
  get  'logout' => 'members#logout', format: false

  namespace :kernel do
    get  'playlist' => 'playlist#index'
    post 'playlist' => 'playlist#update'
    get  'randlist' => 'playlist#randlist'

    get  'tracks'           => 'niconico#index'
    post 'tracks'           => 'niconico#update'
    get  'track_migrations' => 'track_migrations#index'
    post 'track_migrations' => 'track_migrations#update'
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
