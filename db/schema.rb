# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_10_231021) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "athlete_checkins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "offline"
    t.datetime "realizado_em"
    t.bigint "registration_id", null: false
    t.boolean "sincronizado"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_station_id", null: false
    t.index ["registration_id"], name: "index_athlete_checkins_on_registration_id"
    t.index ["volunteer_station_id"], name: "index_athlete_checkins_on_volunteer_station_id"
  end

  create_table "athletes", force: :cascade do |t|
    t.string "cpf"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.date "nascimento"
    t.string "nome"
    t.string "password_digest", null: false
    t.string "sexo"
    t.string "telefone"
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_athletes_on_cpf", unique: true
    t.index ["email_address"], name: "index_athletes_on_email_address", unique: true
  end

  create_table "broadcast_messages", force: :cascade do |t|
    t.string "categoria", default: "info"
    t.text "corpo"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "lida_em"
    t.bigint "sender_id", null: false
    t.datetime "sent_at"
    t.string "titulo"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_station_id"
    t.index ["event_id"], name: "index_broadcast_messages_on_event_id"
    t.index ["sender_id"], name: "index_broadcast_messages_on_sender_id"
    t.index ["volunteer_station_id"], name: "index_broadcast_messages_on_volunteer_station_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "distance_id", null: false
    t.integer "idade_max"
    t.integer "idade_min"
    t.string "nome"
    t.string "sexo"
    t.datetime "updated_at", null: false
    t.index ["distance_id"], name: "index_categories_on_distance_id"
  end

  create_table "certificates", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.datetime "created_at", null: false
    t.datetime "gerado_em"
    t.string "qr_code_hash"
    t.bigint "result_id", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_certificates_on_athlete_id"
    t.index ["qr_code_hash"], name: "index_certificates_on_qr_code_hash", unique: true
    t.index ["result_id"], name: "index_certificates_on_result_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.bigint "category_id"
    t.string "codigo"
    t.datetime "created_at", null: false
    t.bigint "distance_id"
    t.bigint "event_id", null: false
    t.string "tipo"
    t.datetime "updated_at", null: false
    t.integer "uso_atual"
    t.integer "uso_maximo"
    t.datetime "validade"
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.index ["category_id"], name: "index_coupons_on_category_id"
    t.index ["codigo"], name: "index_coupons_on_codigo", unique: true
    t.index ["distance_id"], name: "index_coupons_on_distance_id"
    t.index ["event_id", "codigo"], name: "index_coupons_on_event_id_and_codigo", unique: true
    t.index ["event_id"], name: "index_coupons_on_event_id"
  end

  create_table "distances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.decimal "km", precision: 10, scale: 2, null: false
    t.string "nome"
    t.datetime "updated_at", null: false
    t.integer "vagas_ocupadas"
    t.integer "vagas_total"
    t.index ["event_id"], name: "index_distances_on_event_id"
  end

  create_table "email_campaigns", force: :cascade do |t|
    t.integer "abertos"
    t.string "assunto"
    t.integer "clicados"
    t.datetime "created_at", null: false
    t.datetime "enviado_em"
    t.integer "enviados"
    t.bigint "event_id", null: false
    t.string "segmento"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_email_campaigns_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.text "cancellation_reason"
    t.string "cidade"
    t.datetime "created_at", null: false
    t.text "cronograma"
    t.date "data_largada"
    t.text "descricao"
    t.string "estado"
    t.time "horario_largada"
    t.string "instagram_url"
    t.text "kit_descricao"
    t.integer "limite_atletas"
    t.string "local_partida"
    t.string "nome"
    t.bigint "organizer_id", null: false
    t.string "slug_url"
    t.string "status"
    t.datetime "updated_at", null: false
    t.string "whatsapp_contato"
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
    t.index ["slug_url"], name: "index_events_on_slug_url"
  end

  create_table "incidents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descricao"
    t.bigint "event_id", null: false
    t.string "gravidade"
    t.decimal "km_local", precision: 10, scale: 2, null: false
    t.datetime "ocorrida_em"
    t.bigint "organizer_id", null: false
    t.bigint "registration_id", null: false
    t.string "status"
    t.string "tipo"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_incidents_on_event_id"
    t.index ["organizer_id"], name: "index_incidents_on_organizer_id"
    t.index ["registration_id"], name: "index_incidents_on_registration_id"
  end

  create_table "licenses", force: :cascade do |t|
    t.string "arquivo_pdf"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "orgao"
    t.date "prazo_aprovacao"
    t.date "prazo_solicitacao"
    t.string "status"
    t.string "tipo"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_licenses_on_event_id"
  end

  create_table "lots", force: :cascade do |t|
    t.datetime "abertura"
    t.datetime "created_at", null: false
    t.text "descricao_kit"
    t.bigint "distance_id", null: false
    t.datetime "encerramento"
    t.integer "numero"
    t.decimal "preco", precision: 10, scale: 2, null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "vagas"
    t.index ["distance_id"], name: "index_lots_on_distance_id"
  end

  create_table "nps_responses", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.text "comentario"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.integer "nota_comunicacao"
    t.integer "nota_estrutura"
    t.integer "nota_geral"
    t.integer "nota_organizacao"
    t.integer "nota_percurso"
    t.datetime "respondido_em"
    t.bigint "result_id", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_nps_responses_on_athlete_id"
    t.index ["event_id"], name: "index_nps_responses_on_event_id"
    t.index ["result_id"], name: "index_nps_responses_on_result_id"
  end

  create_table "organizers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "staff"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_organizers_on_email_address"
  end

  create_table "payments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "gateway_id"
    t.string "gateway_provider"
    t.string "metodo", null: false
    t.datetime "pago_em"
    t.bigint "registration_id", null: false
    t.string "status", default: "pendente"
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.datetime "vencimento"
    t.index ["gateway_id"], name: "index_payments_on_gateway_id"
    t.index ["registration_id"], name: "index_payments_on_registration_id"
  end

  create_table "pending_transfers", force: :cascade do |t|
    t.string "cpf_destino"
    t.datetime "created_at", null: false
    t.string "email_destino", null: false
    t.datetime "expira_em", null: false
    t.bigint "registration_id", null: false
    t.string "status", default: "aguardando", null: false
    t.string "token"
    t.bigint "transfer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["expira_em"], name: "index_pending_transfers_on_expira_em"
    t.index ["registration_id"], name: "index_pending_transfers_on_registration_id"
    t.index ["status"], name: "index_pending_transfers_on_status"
    t.index ["transfer_id"], name: "index_pending_transfers_on_transfer_id"
  end

  create_table "photo_registrations", force: :cascade do |t|
    t.integer "confianca_ocr"
    t.boolean "confirmado_manualmente", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "photo_id", null: false
    t.bigint "registration_id", null: false
    t.datetime "updated_at", null: false
    t.index ["photo_id", "registration_id"], name: "index_photo_registrations_unique", unique: true
    t.index ["photo_id"], name: "index_photo_registrations_on_photo_id"
    t.index ["registration_id"], name: "index_photo_registrations_on_registration_id"
  end

  create_table "photos", force: :cascade do |t|
    t.integer "confianca_ocr"
    t.datetime "created_at", null: false
    t.datetime "enviada_em"
    t.bigint "event_id", null: false
    t.string "fotografo_id"
    t.boolean "reconhecido_ia"
    t.string "tipo", default: "atleta", null: false
    t.datetime "updated_at", null: false
    t.string "url_arquivo"
    t.index ["event_id"], name: "index_photos_on_event_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.boolean "aceite_lgpd"
    t.boolean "atestado_enviado"
    t.bigint "athlete_id", null: false
    t.bigint "category_id", null: false
    t.string "chip_code"
    t.string "contato_emergencia"
    t.datetime "created_at", null: false
    t.datetime "data_inscricao"
    t.bigint "distance_id", null: false
    t.bigint "event_id", null: false
    t.string "fone_emergencia"
    t.boolean "kit_entregue"
    t.datetime "kit_entregue_em"
    t.datetime "lgpd_accepted_at"
    t.string "lgpd_accepted_ip"
    t.bigint "lot_id", null: false
    t.integer "numero_dorsal"
    t.string "qr_code_hash"
    t.string "status"
    t.string "tamanho_kit"
    t.datetime "updated_at", null: false
    t.index ["athlete_id", "event_id"], name: "index_registrations_on_athlete_id_and_event_id", unique: true, where: "((status)::text <> ALL ((ARRAY['cancelled'::character varying, 'transferred'::character varying])::text[]))"
    t.index ["athlete_id"], name: "index_registrations_on_athlete_id"
    t.index ["category_id"], name: "index_registrations_on_category_id"
    t.index ["chip_code"], name: "index_registrations_on_chip_code"
    t.index ["distance_id"], name: "index_registrations_on_distance_id"
    t.index ["event_id", "numero_dorsal"], name: "index_registrations_on_event_id_and_numero_dorsal", unique: true, where: "(numero_dorsal IS NOT NULL)"
    t.index ["event_id"], name: "index_registrations_on_event_id"
    t.index ["lot_id"], name: "index_registrations_on_lot_id"
    t.index ["qr_code_hash"], name: "index_registrations_on_qr_code_hash"
  end

  create_table "results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.boolean "homologado", default: false
    t.datetime "homologado_em"
    t.string "pace_medio"
    t.integer "posicao_categoria"
    t.integer "posicao_faixa_etaria"
    t.integer "posicao_geral"
    t.integer "posicao_sexo"
    t.bigint "registration_id", null: false
    t.string "status_finalizacao", default: "concluido"
    t.string "tempo_bruto"
    t.string "tempo_liquido"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_results_on_event_id"
    t.index ["registration_id"], name: "index_results_on_registration_id"
  end

  create_table "routes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "distance_id", null: false
    t.bigint "event_id", null: false
    t.jsonb "geojson_traca", default: {}
    t.jsonb "pontos_apoio", default: []
    t.datetime "updated_at", null: false
    t.index ["distance_id"], name: "index_routes_on_distance_id"
    t.index ["event_id", "distance_id"], name: "index_routes_on_event_id_and_distance_id", unique: true
    t.index ["event_id"], name: "index_routes_on_event_id"
    t.index ["geojson_traca"], name: "index_routes_on_geojson_traca", using: :gin
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "ip_address"
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.string "user_type", null: false
    t.index ["user_type", "user_id"], name: "index_sessions_on_user"
  end

  create_table "sponsor_contracts", force: :cascade do |t|
    t.string "arquivo_pdf"
    t.datetime "assinado_em"
    t.string "cota"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "sponsor_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.decimal "valor_cota", precision: 10, scale: 2, null: false
    t.index ["event_id"], name: "index_sponsor_contracts_on_event_id"
    t.index ["sponsor_id"], name: "index_sponsor_contracts_on_sponsor_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.boolean "ativo"
    t.string "cnpj"
    t.string "contato"
    t.datetime "created_at", null: false
    t.string "email_contato"
    t.integer "inscricoes_geradas"
    t.string "link_indicacao"
    t.string "nome"
    t.string "phone_contato"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "supplier_contracts", force: :cascade do |t|
    t.string "arquivo_pdf"
    t.datetime "assinado_em"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "status"
    t.bigint "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["event_id"], name: "index_supplier_contracts_on_event_id"
    t.index ["supplier_id"], name: "index_supplier_contracts_on_supplier_id"
  end

  create_table "supplier_deliveries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "data_prevista"
    t.date "data_real"
    t.string "descricao"
    t.text "observacao"
    t.string "status"
    t.bigint "supplier_contract_id", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_contract_id"], name: "index_supplier_deliveries_on_supplier_contract_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.decimal "avaliacao_media", precision: 10, scale: 2, default: "0.0", null: false
    t.string "cnpj"
    t.string "contato"
    t.datetime "created_at", null: false
    t.string "email_contato"
    t.string "phone_contato"
    t.string "razao_social"
    t.string "tipo_servico"
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_suppliers_on_cnpj"
  end

  create_table "timings", force: :cascade do |t|
    t.datetime "chip_time"
    t.datetime "created_at", null: false
    t.datetime "gun_time"
    t.decimal "pace_km", precision: 10, scale: 2, null: false
    t.integer "posicao_categoria"
    t.integer "posicao_geral"
    t.bigint "registration_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "waypoint_id", null: false
    t.index ["registration_id", "waypoint_id"], name: "index_timings_on_registration_id_and_waypoint_id", unique: true
    t.index ["registration_id"], name: "index_timings_on_registration_id"
    t.index ["waypoint_id"], name: "index_timings_on_waypoint_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "athlete_destino_id"
    t.bigint "athlete_origem_id", null: false
    t.datetime "concluida_em"
    t.string "cpf_destino"
    t.datetime "created_at", null: false
    t.string "email_destino"
    t.bigint "registration_id", null: false
    t.datetime "solicitada_em"
    t.string "status"
    t.decimal "taxa", precision: 10, scale: 2, default: "0.0", null: false
    t.string "token"
    t.datetime "token_expira_em"
    t.datetime "updated_at", null: false
    t.index ["athlete_destino_id"], name: "index_transfers_on_athlete_destino_id"
    t.index ["athlete_origem_id"], name: "index_transfers_on_athlete_origem_id"
    t.index ["registration_id"], name: "index_transfers_on_registration_id"
    t.index ["status"], name: "index_transfers_on_status"
    t.index ["token"], name: "index_transfers_on_token", unique: true
  end

  create_table "volunteer_shifts", force: :cascade do |t|
    t.datetime "checkin_em"
    t.datetime "created_at", null: false
    t.string "status"
    t.string "turno"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_id", null: false
    t.bigint "volunteer_station_id", null: false
    t.index ["volunteer_id"], name: "index_volunteer_shifts_on_volunteer_id"
    t.index ["volunteer_station_id"], name: "index_volunteer_shifts_on_volunteer_station_id"
  end

  create_table "volunteer_stations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "distance_id"
    t.bigint "event_id", null: false
    t.decimal "km_posicao", precision: 10, scale: 2, default: "0.0", null: false
    t.string "nome"
    t.string "tipo"
    t.datetime "updated_at", null: false
    t.integer "vagas"
    t.index ["distance_id"], name: "index_volunteer_stations_on_distance_id"
    t.index ["event_id"], name: "index_volunteer_stations_on_event_id"
  end

  create_table "volunteers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "funcao_preferida"
    t.string "nome"
    t.string "telefone"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_volunteers_on_email"
  end

  create_table "waitlists", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "data_entrada"
    t.bigint "distance_id", null: false
    t.bigint "event_id", null: false
    t.bigint "lot_id", null: false
    t.integer "posicao"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["athlete_id", "distance_id"], name: "index_waitlists_on_athlete_id_and_distance_id", unique: true
    t.index ["athlete_id"], name: "index_waitlists_on_athlete_id"
    t.index ["category_id"], name: "index_waitlists_on_category_id"
    t.index ["distance_id"], name: "index_waitlists_on_distance_id"
    t.index ["event_id"], name: "index_waitlists_on_event_id"
    t.index ["lot_id"], name: "index_waitlists_on_lot_id"
  end

  create_table "waypoints", force: :cascade do |t|
    t.datetime "closed_at"
    t.integer "closed_by_id"
    t.datetime "created_at", null: false
    t.boolean "eh_chegada"
    t.boolean "eh_largada"
    t.decimal "km", precision: 10, scale: 2, null: false
    t.string "nome"
    t.bigint "route_id", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_waypoints_on_route_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "athlete_checkins", "registrations"
  add_foreign_key "athlete_checkins", "volunteer_stations"
  add_foreign_key "broadcast_messages", "events"
  add_foreign_key "broadcast_messages", "organizers", column: "sender_id"
  add_foreign_key "broadcast_messages", "volunteer_stations"
  add_foreign_key "categories", "distances"
  add_foreign_key "certificates", "athletes"
  add_foreign_key "certificates", "results"
  add_foreign_key "coupons", "categories"
  add_foreign_key "coupons", "distances"
  add_foreign_key "coupons", "events"
  add_foreign_key "distances", "events"
  add_foreign_key "email_campaigns", "events"
  add_foreign_key "events", "organizers"
  add_foreign_key "incidents", "events"
  add_foreign_key "incidents", "organizers"
  add_foreign_key "incidents", "registrations"
  add_foreign_key "licenses", "events"
  add_foreign_key "lots", "distances"
  add_foreign_key "nps_responses", "athletes"
  add_foreign_key "nps_responses", "events"
  add_foreign_key "nps_responses", "results"
  add_foreign_key "payments", "registrations"
  add_foreign_key "pending_transfers", "registrations"
  add_foreign_key "pending_transfers", "transfers"
  add_foreign_key "photo_registrations", "photos"
  add_foreign_key "photo_registrations", "registrations"
  add_foreign_key "photos", "events"
  add_foreign_key "registrations", "athletes"
  add_foreign_key "registrations", "categories"
  add_foreign_key "registrations", "distances"
  add_foreign_key "registrations", "events"
  add_foreign_key "registrations", "lots"
  add_foreign_key "results", "events"
  add_foreign_key "results", "registrations"
  add_foreign_key "routes", "distances"
  add_foreign_key "routes", "events"
  add_foreign_key "sponsor_contracts", "events"
  add_foreign_key "sponsor_contracts", "sponsors"
  add_foreign_key "supplier_contracts", "events"
  add_foreign_key "supplier_contracts", "suppliers"
  add_foreign_key "supplier_deliveries", "supplier_contracts"
  add_foreign_key "timings", "registrations"
  add_foreign_key "timings", "waypoints"
  add_foreign_key "transfers", "athletes", column: "athlete_destino_id"
  add_foreign_key "transfers", "athletes", column: "athlete_origem_id"
  add_foreign_key "transfers", "registrations"
  add_foreign_key "volunteer_shifts", "volunteer_stations"
  add_foreign_key "volunteer_shifts", "volunteers"
  add_foreign_key "volunteer_stations", "distances"
  add_foreign_key "volunteer_stations", "events"
  add_foreign_key "waitlists", "athletes"
  add_foreign_key "waitlists", "categories"
  add_foreign_key "waitlists", "distances"
  add_foreign_key "waitlists", "events"
  add_foreign_key "waitlists", "lots"
  add_foreign_key "waypoints", "routes"
end
