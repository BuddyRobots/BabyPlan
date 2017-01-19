Rails.application.routes.draw do

  mount RuCaptcha::Engine => "/rucaptcha"

  match "/weixin_js_signature" => 'application#signature', :via => :get
  match '/' => 'welcome#weixin', :via => :post

  get 'welcome/courseinfo'
  get 'welcome/managecenter'
  get 'welcome/evaluate'
  get 'welcome/transfer_done'
  get 'welcome/test_image_uploader'

  resources :centers do
  end

  resources :courses do
  end

  resources :deploys do
  end

  namespace :admin do
    resources :sessions do
      collection do
        get :signout
        post :forget_password
        post :change_password
      end
      member do
        post :reset_password
      end
    end
    resources :statistics do
      collection do
        get :client_stats
        get :course_stats
        get :book_stats
      end
    end
    resources :staffs do
      member do
        put :change_center
        put :change_status
      end
    end
    resources :announcements do
      member do
        post :set_publish
        post :upload_photo
      end
    end
    resources :centers do
      member do
        post :set_available
        get :set_current
        post :upload_photo
      end
    end
    resources :courses do
      member do
        post :set_available
        get :get_calendar
      end
    end
    resources :books do
      member do
        get :show_transfer
      end
      collection do
        post :update_setting
      end
    end
    resources :transfers do
    end
  end

  namespace :staff do
    resources :sessions do
      member do
        post :verify
        post :reset_password
      end
      collection do
        post :signup
        post :forget_password
        get :signout
        post :change_password
      end
    end

    resources :statistics do
      collection do
        get :client_stats
        get :course_stats
        get :book_stats
      end
    end

    resources :transfers do
      member do
        get :remove
      end
    end

    resources :reviews do
      member do
        post :show_review
        post :hide_review
      end
    end

    resources :courses do
      collection do
        get :get_id_by_name
        get :next_refund_request
      end
      member do
        post :set_available
        post :upload_photo
        get :show_template
        get :qrcode
        post :signin_client
        get :signin_info
        get :stat
        post :reject_refund
        post :approve_refund
      end
    end

    resources :books do
      member do
        post :set_available
        post :upload_photo
        post :back
        post :lost
        get :download_qrcode
        post :add_to_list
        post :delete_qr_code
      end
      collection do
        get :code_list
        get :merge
        post :auto_merge
        post :mannual_merge
        post :clear_list
        post :download_all_qr
      end
    end

    resources :clients do
      member do
        post :verify
        post :pay_latefee
        post :pay_deposit
        post :refund_deposit
      end
    end

    resources :announcements do
      member do
        post :set_publish
        post :upload_photo
      end
    end
  end

  namespace :staff_mobile do
    resources :sessions do
      collection do
        get :signout
      end
    end
    resources :books do
      member do
        get :back
        post :do_borrow
      end
      collection do
        get :borrow
        get :borrow_result
      end
    end
    resources :transfers do
      member do
        post :add_to_transfer
        post :transfer_arrive
        post :confirm_transfer_out
        post :finish_transfer
        get :confirm_lost
      end
      collection do
        get :list
        get :out_list
        get :in_list
        get :transfer_out
        get :transfer_done
        get :transfer_in
      end
    end
  end

  namespace :user_mobile do
    resources :reviews do
    end
    resources :announcements do
      collection do
        get :more
      end
    end
    resources :books do
      collection do
        get :review
        get :more
      end
      member do
        post :favorite
      end
    end
    resources :centers do
      member do
        get :set_follow
      end
    end
    resources :courses do
      collection do
        get :review
        post :notify
        get :more
      end
      member do
        get :pay_success
        get :signin
        post :pay_finished
        post :pay_failed
        post :request_refund
        post :favorite
      end
    end
    resources :feeds do
      collection do
        get :more
      end
    end
    resources :sessions do
      member do
        post :verify
      end
      collection do
        get :signout
        get :sign_up
        post :signup
        get :forget_password
        post :forget_password_submit_mobile
        post :forget_password_submit_code
        post :update_password
        get :set_password
      end
    end
    resources :settings do
      collection do
        get :book
        get :course
        get :favorite
        post :remove_favorite
        get :message
        get :account
        get :reset_password
        get :sign
        get :profile
        post :update_password
        post :update_profile
        post :upload_avatar
        post :pay_finished
        post :pay_failed
      end
    end
  end

  resources :materials do
  end

  resources :accounts do
    member do
      post :activate
    end
  end


  resources :topics do
    member do
      post :upvote
    end
  end

  


  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'staff/sessions#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get '/admin', to: 'admin/sessions#index'

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
