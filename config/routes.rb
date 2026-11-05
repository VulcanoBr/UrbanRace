Rails.application.routes.draw do
  # =============================================================================
  # 1. ACESSO PÚBLICO & HOME (Ponto de entrada do sistema)
  # =============================================================================
  root to: "public/home#index"

  mount MissionControl::Jobs::Engine => "/jobs"

  get "/certificates/validate/:qr_code_hash", to: "certificates#validate", as: :validate_certificate

  scope module: :public do
    # Landing Page do Evento e Inscrição
    get  "corridas/:slug", to: "events#show", as: :public_event
    get  "corridas/:slug/inscrever", to: "registrations#new", as: :new_public_registration
    post "corridas/:slug/inscrever", to: "registrations#create", as: :public_registrations
    get "corridas/:slug/classificacao", to: "rankings#show", as: :public_event_ranking
    get "corridas/:slug/fotos", to: "photos#show", as: :public_event_photos
    
    # Tracking de Atletas (Dia da Prova)
    get "tracking/:slug", to: "trackings#show", as: :public_tracking
    get "/sobre", to: "pages#sobre", as: :sobre

    get "/privacidade", to: "pages#privacidade", as: :privacidade
    get "/lgpd",        to: "pages#lgpd",        as: :lgpd    

    get  "/contato", to: "contacts#new", as: :contato
    post "/contato", to: "contacts#create"

    get  "transferencia/:token",         to: "transfers#show",   as: :transfer_invite
    post "transferencia/:token/aceitar", to: "transfers#accept", as: :accept_transfer

    # Checkout de Pagamento (Stripe/Pix)
    resources :registrations, only: [] do 
      resource :payment, only: %i[show create], controller: "payments" do 
        member do
        get  :success
        get  :status, defaults: { format: :json }
        post :simulate
      end
      end 
    end


    # Pesquisa NPS (Pós-evento - link via e-mail)
    get  "pesquisa/:registration_token", to: "nps_responses#new", as: :new_nps_response
    post "pesquisa/:registration_token", to: "nps_responses#create", as: :nps_responses
  end

  # =============================================================================
  # 2. AUTENTICAÇÃO (Rails 8.1 Native Authentication)
  # =============================================================================
  resource :session, only: [:new, :create, :destroy]
  resources :passwords, param: :token, only: [:new, :create, :edit, :update]

  # =============================================================================
  # 3. PORTAL DO ATLETA (Logado)
  # =============================================================================
  namespace :athletes do
    resource :dashboard, only: [:show]
    get "/", to: "dashboards#show", as: :root # Atalho para área-do-corredor
    get "area-do-corredor", to: "dashboards#show", as: :area_do_corredor
    
    resources :registrations, only: [:show] do
      resource :transfer, only: [:new, :create] # Transferência de Vaga
      member do
        get :certificate # Download PDF
      end
    end

    resources :results, only: [:index, :show]
    resources :photos, only: [:index] # Galeria identificada por IA
    
    resource :profile, only: [:edit, :update] do
      get :export_data      # LGPD: Portabilidade
      get :privacy_request  # LGPD: Anonimização
      delete :anonymize # Rota para processar a anonimização
    end
  end

  # =============================================================================
  # 4. PAINEL DO ORGANIZADOR (Operacional)
  # =============================================================================
  namespace :operation do
    resources :events, only: [:index] do
      resources :kit_deliveries, only: [:index, :show, :update] do
        collection do
          get :search
        end
      end
      resources :incidents, only: [:new, :create] do
        member do
          get :success # Rota para /operation/events/.../incidents/:id/success
        end
      end
      resources :checkins, only: [:index, :create]
      resources :broadcasts, only: [:index] do
        member do
          post :confirm # Nova rota: /operation/events/:slug/broadcasts/:id/confirm
        end
      end
    end
  end

  # =============================================================================
  # 5. PAINEL DO ORGANIZADOR (Administrativo)
  # =============================================================================
  namespace :organizer do
    root to: "dashboards#show"
    resource :dashboard, only: [:show]

    # Cadastros Globais
    resources :athletes do
      member do
        get :history
      end
    end
    resources :suppliers
    resources :sponsors
    resources :volunteers do
      member do
        get  :assign_shift
        post :create_shift   # ← NOVA rota
      end
    end
    resources :registrations, only: [:index, :new, :show, :create, :edit, :update, :destroy] do
      collection do
        get :update_options # Nova rota para o filtro dinâmico
      end
    end
    resources :supplier_contracts
    resources :sponsor_contracts
    resources :payments, only: [:index, :show] # Financeiro (Entradas)
    
    # Gestão de Eventos e Sub-recursos
    resources :events, param: :id do
      member do
        patch :finish    # PATCH /organizer/events/:slug_url/finish
        patch :cancel    # PATCH /organizer/events/:slug_url/cancel
        post :finalize_status # Gatilho para DNS/DNF
      end

       resources :registrations, only: [:index]

      # post :generate_all_certificates, to: "certificates#create_batch", as: :generate_certificates

      resources :supplier_contracts, only: [:show]
      
      resources :broadcasts

      resource :command_center, only: [:show]

      resources :sponsor_contracts, only: [:show] 

      resources :email_campaigns, only: [:index, :new, :create]

      # Configuração (Hierarquia shallow para URLs limpas)
      resources :distances, shallow: true do
        resources :categories
        resources :lots
      end

      # Logística e Planejamento
      resources :incidents
      resources :routes
      resources :licenses
      resources :checkin_reports, only: [:index]
      resource  :checklist, only: [:show, :update]
      resources :volunteer_shifts, only: [:create, :destroy] 
      resources :volunteer_stations do
        resources :volunteer_shifts
      end

      # Pós-evento e Execução
      resources :results, except: [:new, :create, :show] do
        collection do
          # get :podium # Lista de vencedores para o locutor
          get "results/podium", to: "results#podium", as: :event_podium
          post  :calcular        # Calcula/recalcula todos os resultados
          post  :homologar_todos # Homologa todos de uma vez
          get   :exportar        # Exporta CSV
        end
        member do
          patch :homologar       # Homologa um resultado individual
          post :generate_certificate
        end
      end
      
      resources :timings, only: [:create] # Importador CSV
      resources :certificates, only: [] do
        collection do
          post :create_batch # Gerar todos os PDFs
        end
      end
      
      resources :photos, only: [:index, :create, :destroy] do
        collection do
          post :bulk_upload # Upload em lote para IA
        end
      end

      resource :nps_report, only: [:show] # Dashboard de satisfação
      resource :cbat_export, only: [:show] # Exportação federativa
    end
    resources :categories
    resources :lots
  end

  # =============================================================================
  # 6. SISTEMA & INTEGRAÇÕES
  # =============================================================================
  
  # Webhooks (Confirmação de Pagamento)
  post "webhooks/stripe", to: "webhooks/stripe#create"

  # API para Parceiros (Cronometragem Terceirizada)
  namespace :api do
    namespace :v1 do
      resources :timings, only: [:create]
    end
  end

  # PWA (Rails 8 nativo para Check-in Offline)
  get "/manifest.json", to: "pwa#manifest", as: :pwa_manifest
  get "/service-worker.js", to: "pwa#service_worker", as: :pwa_service_worker
end