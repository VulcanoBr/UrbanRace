import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["eventSelect", "distanceSelect"];
  static values = { url: String };

  // Disparado quando o select de EVENTO muda
  eventChanged(event) {
    const eventId = event.target.value;

    this.fetchOptions({
      event_id: eventId,
      distance_id: "", // reseta distância pois evento mudou
      athlete_id: "", // reseta atleta pois evento mudou
      category_id: "",
      lot_id: "",
    });
  }

  // Disparado quando o select de DISTÂNCIA muda
  distanceChanged(event) {
    const distanceId = event.target.value;

    const eventId = this.hasEventSelectTarget
      ? this.eventSelectTarget.value
      : "";

    // Pega o atleta atualmente selecionado para preservá-lo
    const athleteSelect = this.element.querySelector(
      "select[name*='athlete_id']",
    );
    const athleteId = athleteSelect ? athleteSelect.value : "";

    this.fetchOptions({
      event_id: eventId,
      distance_id: distanceId,
      athlete_id: athleteId, // preserva o atleta já escolhido
      category_id: "",
      lot_id: "",
    });
  }

  fetchOptions(params) {
    const url = new URL(this.urlValue, window.location.origin);

    Object.entries(params).forEach(([k, v]) => {
      if (v !== "" && v !== null && v !== undefined) {
        url.searchParams.set(k, v);
      }
    });

    fetch(url.toString(), {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          ?.content,
      },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html))
      .catch((err) => console.error("[dynamic-select]", err));
  }
}
