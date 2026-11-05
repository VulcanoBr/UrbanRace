import { Controller } from "@hotwired/stimulus";

const LEVELS = [
  {
    text: "Muito fraca",
    color: "bg-red-600",
    width: "20%",
  },
  {
    text: "Fraca",
    color: "bg-orange-500",
    width: "40%",
  },
  {
    text: "Boa",
    color: "bg-yellow-500",
    width: "60%",
  },
  {
    text: "Forte",
    color: "bg-blue-600",
    width: "80%",
  },
  {
    text: "Excelente",
    color: "bg-green-600",
    width: "100%",
  },
];

export default class extends Controller {
  static targets = [
    "password",
    "confirmation",

    "progress",
    "level",

    "length",
    "uppercase",
    "lowercase",
    "number",
    "special",

    "match",

    "submit",
  ];

  connect() {
    this.analyze();
  }

  analyze() {
    const password = this.passwordTarget.value;

    const rules = {
      length: password.length >= 8,

      uppercase: /[A-Z]/.test(password),

      lowercase: /[a-z]/.test(password),

      number: /\d/.test(password),

      special: /[^A-Za-z0-9]/.test(password),
    };

    let score = 0;

    Object.values(rules).forEach((value) => {
      if (value) score++;
    });

    this.updateRule(this.lengthTarget, rules.length);
    this.updateRule(this.uppercaseTarget, rules.uppercase);
    this.updateRule(this.lowercaseTarget, rules.lowercase);
    this.updateRule(this.numberTarget, rules.number);
    this.updateRule(this.specialTarget, rules.special);

    this.updateStrength(score);

    this.compare();
  }

  compare() {
    const equal =
      this.passwordTarget.value !== "" &&
      this.passwordTarget.value === this.confirmationTarget.value;

    if (equal) {
      this.matchTarget.innerHTML = "✔ As senhas coincidem";

      this.matchTarget.className = "text-sm font-bold text-green-600";
    } else {
      this.matchTarget.innerHTML = "○ As senhas devem coincidir";

      this.matchTarget.className = "text-sm font-bold text-gray-500";
    }

    this.updateSubmit();
  }

  updateRule(element, valid) {
    if (valid) {
      element.innerHTML =
        "✔ " + element.textContent.replace(/^✔|^○/, "").trim();

      element.className = "text-green-600 font-semibold";
    } else {
      element.innerHTML =
        "○ " + element.textContent.replace(/^✔|^○/, "").trim();

      element.className = "text-gray-500";
    }
  }

  updateStrength(score) {
    if (score === 0) {
      this.progressTarget.style.width = "0%";

      this.progressTarget.className = "h-full rounded-full";

      this.levelTarget.innerHTML = "Digite uma senha";

      this.levelTarget.className = "mt-2 text-sm font-bold text-gray-500";

      return;
    }

    const level = LEVELS[score - 1];

    this.progressTarget.style.width = level.width;

    this.progressTarget.className = `h-full rounded-full transition-all duration-300 ${level.color}`;

    this.levelTarget.innerHTML = level.text;

    this.levelTarget.className = "mt-2 text-sm font-bold text-gray-700";
  }

  updateSubmit() {
    const password = this.passwordTarget.value;

    const valid =
      password.length >= 8 &&
      /[A-Z]/.test(password) &&
      /[a-z]/.test(password) &&
      /\d/.test(password) &&
      /[^A-Za-z0-9]/.test(password) &&
      password === this.confirmationTarget.value;

    this.submitTarget.disabled = !valid;
  }

  toggleVisibility(event) {
    const target = event.currentTarget.dataset.passwordTarget;

    const input =
      target === "password" ? this.passwordTarget : this.confirmationTarget;

    if (input.type === "password") {
      input.type = "text";

      event.currentTarget.innerHTML = "🙈";
    } else {
      input.type = "password";

      event.currentTarget.innerHTML = "👁";
    }
  }
}
