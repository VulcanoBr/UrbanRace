import { Controller } from "@hotwired/stimulus";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

export default class extends Controller {
  static targets = ["map"];

  static values = {
    geojson: Object,
    pontosApoio: Array,
  };

  connect() {
    this.initializeMap();
    this.loadRoute();
    this.loadSupportPoints();
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
  }

  // ---------------------------------------------------------
  // MAPA
  // ---------------------------------------------------------

  initializeMap() {
    this.map = L.map(this.mapTarget, {
      center: [-22.9068, -43.1729],
      zoom: 12,
      zoomControl: true,
    });

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(this.map);
  }

  // ---------------------------------------------------------
  // ROTA
  // ---------------------------------------------------------

  loadRoute() {
    if (!this.hasGeojsonValue) {
      console.warn("GeoJSON não encontrado.");
      return;
    }

    const geojson = this.geojsonValue;

    if (!geojson || Object.keys(geojson).length === 0) {
      console.warn("GeoJSON está vazio.");
      return;
    }

    console.log("GeoJSON carregado:", geojson);

    const routeLayer = L.geoJSON(geojson, {
      style: {
        color: "#2563eb",
        weight: 6,
        opacity: 0.9,
      },
    }).addTo(this.map);

    let firstPoint = null;
    let lastPoint = null;

    routeLayer.eachLayer((layer) => {
      if (layer instanceof L.Polyline && !(layer instanceof L.Polygon)) {
        const latLngs = layer.getLatLngs();

        if (latLngs.length >= 2) {
          firstPoint = latLngs[0];
          lastPoint = latLngs[latLngs.length - 1];
        }
      }
    });

    /*
     * Criamos largada e chegada somente como fallback.
     *
     * Se os pontos já estiverem em pontos_apoio,
     * loadSupportPoints() também irá criá-los.
     *
     * Para evitar duplicação, verificamos os pontos
     * existentes antes.
     */

    const pontos = this.pontosApoioValue || [];

    const temLargada = pontos.some((ponto) => ponto.tipo === "largada");

    const temChegada = pontos.some((ponto) => ponto.tipo === "chegada");

    if (firstPoint && !temLargada) {
      this.createMarker(firstPoint, "Largada", "largada");
    }

    if (lastPoint && !temChegada) {
      this.createMarker(lastPoint, "Chegada", "chegada");
    }

    const bounds = routeLayer.getBounds();

    if (bounds.isValid()) {
      this.map.fitBounds(bounds, {
        padding: [50, 50],
      });
    }
  }

  // ---------------------------------------------------------
  // PONTOS DE APOIO
  // ---------------------------------------------------------

  loadSupportPoints() {
    if (!this.hasPontosApoioValue) {
      console.warn("Pontos de apoio não encontrados.");
      return;
    }

    const pontos = this.pontosApoioValue;

    if (!Array.isArray(pontos)) {
      console.warn("pontosApoioValue não é um Array:", pontos);

      return;
    }

    console.log("Pontos carregados:", pontos);

    pontos.forEach((ponto) => {
      const latitude = parseFloat(ponto.latitude ?? ponto.lat);

      const longitude = parseFloat(ponto.longitude ?? ponto.lng);

      if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
        console.warn("Ponto inválido:", ponto);

        return;
      }

      let tipo = ponto.tipo || "apoio";

      let label = ponto.nome || "Ponto de apoio";

      this.createMarker([latitude, longitude], label, tipo, ponto);
    });
  }

  // ---------------------------------------------------------
  // MARCADORES
  // ---------------------------------------------------------

  createMarker(latlng, label, tipo = "apoio", ponto = {}) {
    const icon = this.createCustomIcon(tipo);

    const marker = L.marker(latlng, {
      icon: icon,
      zIndexOffset: this.getZIndex(tipo),
    });

    marker.bindTooltip(this.escapeHtml(label), {
      permanent: true,
      direction: "top",
      offset: [0, -18],
      className: `route-marker-tooltip route-marker-${tipo}`,
    });

    const popupContent = `
      <div class="text-sm">
        <strong>${this.escapeHtml(label)}</strong>
        <br>
        <span>${this.escapeHtml(tipo)}</span>
      </div>
    `;

    marker.bindPopup(popupContent);

    marker.addTo(this.map);

    return marker;
  }

  // ---------------------------------------------------------
  // ÍCONE CUSTOMIZADO
  // ---------------------------------------------------------

  createCustomIcon(tipo) {
    let classe = "route-marker-apoio";
    let simbolo = "💧";

    switch (tipo) {
      case "largada":
        classe = "route-marker-largada";
        simbolo = "▶";
        break;

      case "chegada":
        classe = "route-marker-chegada";
        simbolo = "🏁";
        break;

      case "apoio":
      default:
        classe = "route-marker-apoio";
        simbolo = "💧";
        break;
    }

    return L.divIcon({
      className: "route-custom-marker-wrapper",

      html: `
        <div class="route-custom-marker ${classe}">
          <span>${simbolo}</span>
        </div>
      `,

      iconSize: [42, 42],
      iconAnchor: [21, 21],
      popupAnchor: [0, -21],
      tooltipAnchor: [0, -21],
    });
  }

  // ---------------------------------------------------------
  // Z-INDEX
  // ---------------------------------------------------------

  getZIndex(tipo) {
    switch (tipo) {
      case "largada":
        return 1000;

      case "chegada":
        return 1000;

      case "apoio":
      default:
        return 500;
    }
  }

  // ---------------------------------------------------------
  // SEGURANÇA
  // ---------------------------------------------------------

  escapeHtml(value) {
    const div = document.createElement("div");

    div.textContent = String(value ?? "");

    return div.innerHTML;
  }
}
