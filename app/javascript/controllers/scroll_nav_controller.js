import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    window.addEventListener("scroll", this.onScroll.bind(this));
  }

  onScroll() {
    if (window.scrollY > 50) {
      this.element.classList.add(
        "bg-green-950/90",
        "backdrop-blur-md",
        "shadow-xl",
        "py-2",
      );
      this.element.classList.remove("py-4");
    } else {
      this.element.classList.remove(
        "bg-green-950/90",
        "backdrop-blur-md",
        "shadow-xl",
        "py-2",
      );
      this.element.classList.add("py-4");
    }
  }
}
