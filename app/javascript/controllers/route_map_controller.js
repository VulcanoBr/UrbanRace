import { Controller } from "@hotwired/stimulus";
import L from "leaflet";
import "leaflet-draw";
import "leaflet-draw/dist/leaflet.draw.css";

export default class extends Controller {
  static targets = [
    "map",
    "geojson",
    "pontosApoio",
    "status",
    "distanciaCalculada",
  ];

  static values = {
    latitude: {
      type: Number,
      default: -22.9068,
    },

    longitude: {
      type: Number,
      default: -43.1729,
    },

    zoom: {
      type: Number,
      default: 14,
    },

    geojson: {
      type: String,
      default: "",
    },

    pontosApoio: {
      type: String,
      default: "[]",
    },
  };

  connect() {
    this.mode = null;
    this.activeDrawHandler = null;

    this.initializeMap();
    this.initializeLayers();
    this.initializeDraw();

    this.loadExistingRoute();
    this.loadSupportPoints();

    this.updateStatus("Selecione uma ferramenta para começar.");
  }

  disconnect() {
    this.stopCurrentMode();

    if (this.map) {
      this.map.remove();
      this.map = null;
    }
  }

  // =========================================================
  // MAPA
  // =========================================================

  initializeMap() {
    this.map = L.map(this.mapTarget).setView(
      [this.latitudeValue, this.longitudeValue],
      this.zoomValue,
    );

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,

      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(this.map);

    this.map.on("click", (event) => this.handleMapClick(event));
  }

  // =========================================================
  // CAMADAS
  // =========================================================

  initializeLayers() {
    this.routeLayer = new L.FeatureGroup();

    this.supportLayer = new L.FeatureGroup();

    this.map.addLayer(this.routeLayer);
    this.map.addLayer(this.supportLayer);
  }

  // =========================================================
  // LEAFLET DRAW
  // =========================================================

  initializeDraw() {
    this.drawControl = new L.Control.Draw({
      position: "topright",

      draw: {
        polyline: {
          shapeOptions: {
            color: "#2563eb",
            weight: 5,
            opacity: 0.9,
          },

          metric: true,
          feet: false,
        },

        polygon: false,
        rectangle: false,
        circle: false,
        circlemarker: false,
        marker: false,
      },

      edit: {
        featureGroup: this.routeLayer,
        remove: true,
      },
    });

    this.map.addControl(this.drawControl);

    this.registerDrawEvents();
  }

  registerDrawEvents() {
    this.map.on(L.Draw.Event.CREATED, (event) => {
      if (event.layerType !== "polyline") {
        return;
      }

      this.handleRouteCreated(event.layer);
    });

    this.map.on(L.Draw.Event.EDITED, () => {
      this.updateRouteData();
      this.updateStartFinishFromRoute();

      this.updateStatus("Percurso atualizado.");
    });

    this.map.on(L.Draw.Event.DELETED, () => {
      this.updateRouteData();

      this.updateStatus("Percurso removido.");
    });
  }

  // =========================================================
  // BOTÃO: LARGADA
  // =========================================================

  startStartPoint() {
    this.stopCurrentMode();

    this.mode = "largada";

    this.updateStatus("Clique no mapa para definir a largada.");
  }

  // =========================================================
  // BOTÃO: TRAÇAR ROTA
  // =========================================================

  startRoute() {
    this.stopCurrentMode();

    this.mode = "rota";

    this.updateStatus("Desenhe o percurso no mapa.");

    this.startPolylineDrawing();
  }

  startPolylineDrawing() {
    if (this.activeDrawHandler) {
      this.activeDrawHandler.disable();
    }

    this.activeDrawHandler = new L.Draw.Polyline(this.map, {
      shapeOptions: {
        color: "#2563eb",
        weight: 5,
        opacity: 0.9,
      },

      metric: true,
      feet: false,
    });

    this.activeDrawHandler.enable();
  }

  // =========================================================
  // BOTÃO: PONTO DE APOIO
  // =========================================================

  startSupportPoint() {
    this.stopCurrentMode();

    this.mode = "apoio";

    this.updateStatus("Clique no mapa para adicionar um ponto de apoio.");
  }

  // =========================================================
  // BOTÃO: CHEGADA
  // =========================================================

  startFinishPoint() {
    this.stopCurrentMode();

    this.mode = "chegada";

    this.updateStatus("Clique no mapa para definir a chegada.");
  }

  // =========================================================
  // CLIQUE NO MAPA
  // =========================================================

  handleMapClick(event) {
    if (!this.mode) {
      return;
    }

    const latlng = event.latlng;

    switch (this.mode) {
      case "largada":
        this.createStartPoint(latlng);
        break;

      case "apoio":
        this.createSupportPoint(latlng);
        break;

      case "chegada":
        this.createFinishPoint(latlng);
        break;
    }
  }

  // =========================================================
  // LARGADA
  // =========================================================

  createStartPoint(latlng) {
    const pontos = this.getSupportPoints();

    const existingIndex = pontos.findIndex((ponto) => ponto.tipo === "largada");

    const ponto = {
      tipo: "largada",
      nome: "Largada",
      latitude: latlng.lat,
      longitude: latlng.lng,
    };

    if (existingIndex >= 0) {
      pontos[existingIndex] = ponto;
    } else {
      pontos.push(ponto);
    }

    this.saveSupportPoints(pontos);

    this.renderSupportPoints();

    this.mode = null;

    this.updateStatus("Largada definida.");
  }

  // =========================================================
  // CHEGADA
  // =========================================================

  createFinishPoint(latlng) {
    const pontos = this.getSupportPoints();

    const existingIndex = pontos.findIndex((ponto) => ponto.tipo === "chegada");

    const ponto = {
      tipo: "chegada",
      nome: "Chegada",
      latitude: latlng.lat,
      longitude: latlng.lng,
    };

    if (existingIndex >= 0) {
      pontos[existingIndex] = ponto;
    } else {
      pontos.push(ponto);
    }

    this.saveSupportPoints(pontos);

    this.renderSupportPoints();

    this.mode = null;

    this.updateStatus("Chegada definida.");
  }

  // =========================================================
  // PONTO DE APOIO
  // =========================================================

  createSupportPoint(latlng) {
    const pontos = this.getSupportPoints();

    const nome = window.prompt("Nome do ponto de apoio:", "Ponto de Apoio");

    if (nome === null) {
      return;
    }

    pontos.push({
      tipo: "apoio",
      nome: nome.trim() || "Ponto de Apoio",
      latitude: latlng.lat,
      longitude: latlng.lng,
    });

    this.saveSupportPoints(pontos);

    this.renderSupportPoints();

    this.updateStatus("Ponto de apoio adicionado.");

    // Continua no modo apoio para permitir
    // vários pontos consecutivos.
    this.mode = "apoio";
  }

  // =========================================================
  // ROTA CRIADA
  // =========================================================

  handleRouteCreated(layer) {
    this.routeLayer.clearLayers();

    this.routeLayer.addLayer(layer);

    this.activeDrawHandler = null;

    this.mode = null;

    this.updateRouteData();

    this.updateStartFinishFromRoute();

    this.updateStatus("Percurso criado com sucesso.");
  }

  // =========================================================
  // GEOJSON
  // =========================================================

  updateRouteData() {
    const layers = this.routeLayer.getLayers();

    const route = layers.find((layer) => layer instanceof L.Polyline);

    if (!route) {
      this.geojsonTarget.value = "";

      this.updateDistance();

      return;
    }

    const coordinates = route
      .getLatLngs()
      .map((point) => [point.lng, point.lat]);

    const geojson = {
      type: "Feature",
      properties: {},
      geometry: {
        type: "LineString",
        coordinates,
      },
    };

    this.geojsonTarget.value = JSON.stringify(geojson);

    this.updateDistance(route);
  }

  // =========================================================
  // ATUALIZAR LARGADA / CHEGADA PELA ROTA
  // =========================================================

  updateStartFinishFromRoute() {
    const route = this.routeLayer
      .getLayers()
      .find((layer) => layer instanceof L.Polyline);

    if (!route) {
      return;
    }

    const latlngs = route.getLatLngs();

    if (latlngs.length < 2) {
      return;
    }

    const pontos = this.getSupportPoints();

    const start = latlngs[0];

    const finish = latlngs[latlngs.length - 1];

    const startIndex = pontos.findIndex((ponto) => ponto.tipo === "largada");

    const finishIndex = pontos.findIndex((ponto) => ponto.tipo === "chegada");

    const startPoint = {
      tipo: "largada",
      nome: "Largada",
      latitude: start.lat,
      longitude: start.lng,
    };

    const finishPoint = {
      tipo: "chegada",
      nome: "Chegada",
      latitude: finish.lat,
      longitude: finish.lng,
    };

    if (startIndex >= 0) {
      pontos[startIndex] = startPoint;
    } else {
      pontos.push(startPoint);
    }

    if (finishIndex >= 0) {
      pontos[finishIndex] = finishPoint;
    } else {
      pontos.push(finishPoint);
    }

    this.saveSupportPoints(pontos);

    this.renderSupportPoints();
  }

  // =========================================================
  // PONTOS DE APOIO
  // =========================================================

  getSupportPoints() {
    if (!this.hasPontosApoioTarget || !this.pontosApoioTarget.value) {
      return [];
    }

    try {
      const pontos = JSON.parse(this.pontosApoioTarget.value);

      return Array.isArray(pontos) ? pontos : [];
    } catch {
      return [];
    }
  }

  saveSupportPoints(pontos) {
    this.pontosApoioTarget.value = JSON.stringify(pontos);
  }

  renderSupportPoints() {
    this.supportLayer.clearLayers();

    const pontos = this.getSupportPoints();

    pontos.forEach((ponto) => {
      const latitude = parseFloat(ponto.latitude);

      const longitude = parseFloat(ponto.longitude);

      if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
        return;
      }

      const marker = L.marker([latitude, longitude], {
        icon: this.createPointIcon(ponto.tipo),
      });

      marker.bindPopup(
        `<strong>${this.escapeHtml(
          ponto.nome || this.labelForType(ponto.tipo),
        )}</strong>`,
      );

      this.supportLayer.addLayer(marker);
    });
  }

  // =========================================================
  // ÍCONES
  // =========================================================

  createPointIcon(tipo) {
    let color = "#f59e0b";

    if (tipo === "largada") {
      color = "#16a34a";
    }

    if (tipo === "chegada") {
      color = "#dc2626";
    }

    return L.divIcon({
      className: "",

      html: `
        <div
          style="
            width: 30px;
            height: 30px;
            border-radius: 9999px;
            background: ${color};
            border: 3px solid white;
            box-shadow: 0 2px 6px rgba(0,0,0,.35);
          "
        ></div>
      `,

      iconSize: [30, 30],
      iconAnchor: [15, 15],
      popupAnchor: [0, -15],
    });
  }

  labelForType(tipo) {
    switch (tipo) {
      case "largada":
        return "Largada";

      case "chegada":
        return "Chegada";

      default:
        return "Ponto de apoio";
    }
  }

  // =========================================================
  // CARREGAR ROTA EXISTENTE
  // =========================================================

  loadExistingRoute() {
    let rawGeojson = "";

    if (this.hasGeojsonTarget) {
      rawGeojson = this.geojsonTarget.value;
    }

    if (!rawGeojson && this.hasGeojsonValue) {
      rawGeojson = this.geojsonValue;
    }

    if (!this.hasGeojsonValue || !this.geojsonValue) {
      return;
    }

    try {
      const geojson = JSON.parse(this.geojsonValue);

      const layer = L.geoJSON(geojson, {
        style: {
          color: "#2563eb",
          weight: 5,
          opacity: 0.9,
        },
      });

      layer.eachLayer((item) => {
        this.routeLayer.addLayer(item);
      });

      if (this.routeLayer.getLayers().length > 0) {
        this.map.fitBounds(this.routeLayer.getBounds(), {
          padding: [30, 30],
        });
      }

      this.updateRouteData();
    } catch (error) {
      console.error("Erro ao carregar GeoJSON:", error);
    }
  }

  // =========================================================
  // CARREGAR PONTOS
  // =========================================================

  loadSupportPoints() {
    this.renderSupportPoints();
  }

  // =========================================================
  // DISTÂNCIA
  // =========================================================

  updateDistance(route = null) {
    if (!this.hasDistanciaCalculadaTarget) {
      return;
    }

    if (!route) {
      this.distanciaCalculadaTarget.textContent = "0,00 km";

      return;
    }

    const latlngs = route.getLatLngs();

    let distance = 0;

    for (let i = 1; i < latlngs.length; i++) {
      distance += latlngs[i - 1].distanceTo(latlngs[i]);
    }

    const kilometers = distance / 1000;

    this.distanciaCalculadaTarget.textContent = `${kilometers
      .toFixed(2)
      .replace(".", ",")} km`;
  }

  // =========================================================
  // CANCELAR MODO
  // =========================================================

  stopCurrentMode() {
    this.mode = null;

    if (this.activeDrawHandler) {
      this.activeDrawHandler.disable();
      this.activeDrawHandler = null;
    }
  }

  // =========================================================
  // STATUS
  // =========================================================

  updateStatus(message) {
    if (!this.hasStatusTarget) {
      return;
    }

    this.statusTarget.textContent = message;
  }

  // =========================================================
  // SEGURANÇA HTML
  // =========================================================

  escapeHtml(value) {
    const div = document.createElement("div");

    div.textContent = String(value ?? "");

    return div.innerHTML;
  }
}
