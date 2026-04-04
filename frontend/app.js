function getApiBase() {
  return document.getElementById("apiBase").value.replace(/\/$/, "");
}

function pretty(value) {
  return JSON.stringify(value, null, 2);
}

function asNumber(formData, key) {
  return Number(formData.get(key));
}

async function postJson(path, body) {
  const response = await fetch(`${getApiBase()}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  });

  const text = await response.text();
  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch {
    parsed = { raw: text };
  }

  if (!response.ok) {
    throw new Error(pretty(parsed));
  }

  return parsed;
}

function bindForm(formId, resultId, builder, path) {
  const form = document.getElementById(formId);
  const result = document.getElementById(resultId);

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    result.textContent = "Loading...";

    try {
      const fd = new FormData(form);
      const payload = builder(fd);
      const data = await postJson(path, payload);
      result.textContent = pretty(data);
    } catch (error) {
      result.textContent = `Request failed:\n${error.message}`;
    }
  });
}

document.getElementById("healthBtn").addEventListener("click", async () => {
  const status = document.getElementById("healthStatus");
  status.textContent = "Checking...";

  try {
    const response = await fetch(`${getApiBase()}/health`);
    const data = await response.json();
    status.textContent = `Online: ${data.status} (${data.bot})`;
  } catch {
    status.textContent = "Backend unreachable";
  }
});

bindForm(
  "onboardingForm",
  "onboardingResult",
  (fd) => ({
    user_id: String(fd.get("user_id")),
    cycle_length: asNumber(fd, "cycle_length"),
    last_period_date: String(fd.get("last_period_date")),
    health_goals: String(fd.get("health_goals")).split(",").map((x) => x.trim()).filter(Boolean),
    concerns: String(fd.get("concerns")).split(",").map((x) => x.trim()).filter(Boolean),
    age: asNumber(fd, "age"),
    bmi: asNumber(fd, "bmi")
  }),
  "/onboarding"
);

bindForm(
  "chatForm",
  "chatResult",
  (fd) => ({
    user_id: String(fd.get("user_id")),
    message: String(fd.get("message")),
    use_rag: fd.get("use_rag") === "on"
  }),
  "/chat"
);

bindForm(
  "endoForm",
  "endoResult",
  (fd) => ({
    age: asNumber(fd, "age"),
    menstrual_irregularity: asNumber(fd, "menstrual_irregularity"),
    chronic_pain_level: asNumber(fd, "chronic_pain_level"),
    hormone_level_abnormality: asNumber(fd, "hormone_level_abnormality"),
    infertility: asNumber(fd, "infertility"),
    bmi: asNumber(fd, "bmi")
  }),
  "/endometriosis-screening"
);

bindForm(
  "pcosForm",
  "pcosResult",
  (fd) => ({
    age: asNumber(fd, "age"),
    bmi: asNumber(fd, "bmi"),
    menstrual_irregularity: asNumber(fd, "menstrual_irregularity"),
    hirsutism: asNumber(fd, "hirsutism"),
    acne: asNumber(fd, "acne")
  }),
  "/pcos-screening"
);
