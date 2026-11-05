# spec/requests/organizer/routes_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organizer::Routes (Percursos)", type: :request do
  let!(:organizer) { create(:organizer) }
  let!(:event)     { create(:event, organizer: organizer, status: "draft") }
  let!(:distance)  { create(:distance, event: event) }
  let!(:route)     { create(:route, event: event, distance: distance) }

  before do
    sign_in_as_organizer(organizer)
  end

  describe "GET /organizer/events/:event_id/routes" do
    it "retorna 200" do
      get organizer_event_routes_path(event.slug_url)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /organizer/events/:event_id/routes/:id/edit" do
    it "retorna 200" do
      get edit_organizer_event_route_path(event.slug_url, route)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /organizer/events/:event_id/routes/:id" do
    it "atualiza o percurso e redireciona" do
      novo_geojson = {
        "type" => "Feature",
        "geometry" => {
          "type" => "LineString",
          "coordinates" => [[-43.1000, -22.9000], [-43.1100, -22.9100]]
        }
      }

      patch organizer_event_route_path(event.slug_url, route),
            params: {
              organizer_route_form: {
                distance_id: distance.id,
                geojson_traca: novo_geojson.to_json
              }
            }

      expect(response).to have_http_status(:redirect)
      expect(route.reload.geojson_traca).to eq(novo_geojson)
    end
  end

  describe "POST /organizer/events/:event_id/routes" do
    it "cria novo percurso" do
      new_distance = create(:distance, event: event)
      geojson = {
        "type" => "Feature",
        "geometry" => {
          "type" => "LineString",
          "coordinates" => [[-43.1000, -22.9000], [-43.1100, -22.9100]]
        }
      }

      expect {
        post organizer_event_routes_path(event.slug_url),
             params: {
               organizer_route_form: {
                 distance_id: new_distance.id,
                 geojson_traca: geojson.to_json
               }
             }
      }.to change(Route, :count).by(1)

      expect(response).to have_http_status(:redirect)
    end
  end
end