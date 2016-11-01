Rails.application.routes.draw do

  mount RuCaptcha::Engine => "/rucaptcha"

  get 'welcome/index'
  get 'welcome/test'
  get 'welcome/search_new'
  get 'welcome/search_book'
  get 'welcome/frontpage'
  get 'welcome/usercenter'
  get 'welcome/centerbook'
  get 'welcome/register'
  get 'welcome/signin'
  get 'welcome/centernotice'
  get 'welcome/haidianbook'
  get 'welcome/fengtaicenter'
  get 'welcome/centercourse'
  get 'welcome/robotclass'
  get 'welcome/evaluate'
  get 'welcome/robotcourse'
  get 'welcome/haidiancenter'
  get 'welcome/noticedescription'
  get 'welcome/mybook'
  get 'welcome/mycourse'
  get 'welcome/searchresult'
  get 'welcome/editdemo'
  get 'welcome/searchlink'
  get 'welcome/systemmessage'
  get 'welcome/collect'
  get 'welcome/courseinfo'
  get 'welcome/course_paid'
  get 'welcome/course_end'
  get 'welcome/course_show'
  get 'welcome/forget_password'
  get 'welcome/set_password'
  get 'welcome/wechat_pay'
  get 'welcome/set_center'
  get 'welcome/set_center_2'
  get 'welcome/set'


  get 'welcome/m_frontpage'
  get 'welcome/m_book_borrow'
  get 'welcome/m_borrow'
  get 'welcome/m_unreturn'
  get 'welcome/m_return'
  get 'welcome/m_transfer'
  get 'welcome/m_transfer_desc'
  get 'welcome/m_transfer_lost_desc'
  get 'welcome/m_transfer_record'
  get 'welcome/m_transfer_out_record'
  get 'welcome/m_transfer_in'
  get 'welcome/m_transfer_out'
  get 'welcome/m_transfer_start'
  get 'welcome/m_transfer_continue'
  get 'welcome/m_transfer_back'
  get 'welcome/m_back'
  get 'welcome/m_transport_in'
  get 'welcome/m_transport_out'
  get 'welcome/m_transport_out_end'
  get 'welcome/m_continue_transport_out'
  get 'welcome/m_transport'
  get 'welcome/m_transport_lost'
  get 'welcome/m_transport_to_center'
  get 'welcome/m_continue_borrow'




  get 'welcome/managecenter'

  get 'welcome/test_image_uploader'

  match '/' => 'welcome#weixin', :via => :post

  resources :centers do
  end

  resources :courses do
  end

  namespace :client do
    resources :users do
    end
    resources :sessions do
      collection do
        get :signin_page
        get :signup_page
      end
    end
    resources :infos do
    end
    resources :centers do
    end
  end

  namespace :admin do
    resources :sessions do
      collection do
        get :signout
        post :forget_password
      end
      member do
        post :reset_password
      end
    end
    resources :statistics do
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
      end
    end

    resources :statistics do
    end

    resources :transfers do
    end

    resources :courses do
      collection do
        get :get_id_by_name
      end
      member do
        post :set_available
        post :upload_photo
        get :show_template
        get :qrcode
      end
    end

    resources :books do
      member do
        post :set_available
        post :upload_photo
      end
    end

    resources :clients do
      member do
        post :verify
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
    end
    resources :books do
      collection do
        get :borrow
        get :borrow_result
        get :back
      end
    end
    resources :transfers do
      collection do
        get :list
        get :out_list
        get :in_list
        get :transfer_out
        get :transfer_in
        get :confirm_lost
      end
    end
  end

  namespace :user_mobile do
    resources :announcements do
    end
    resources :books do
    end
    resources :centers do
    end
    resources :courses do
      collection do
        get :review
      end
    end
    resources :feeds do
    end
    resources :sessions do
      member do
        post :verify
      end
      collection do
        get :sign_up
        post :signup
        get :forget_password
        get :set_password
      end
    end
    resources :settings do
      collection do
        get :book
        get :course
        get :collect
        get :message
        get :account
        get :reset_password
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
