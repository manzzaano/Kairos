// Gemma 3 27B (último modelo Gemma disponible via Google AI API)
// Requiere GEMINI_API_KEY configurada en Supabase secrets
const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemma-3-27b-it:generateContent";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function fallbackResponse(tasks: unknown[]) {
  return Response.json(
    {
      optimized: tasks,
      explanation:
        "Aviso: no se pudo optimizar vía Gemini. Se devuelven las tareas sin reordenar.",
    },
    { headers: corsHeaders },
  );
}

export async function handler(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (!req.headers.get("Authorization")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { tasks } = await req.json();
  const apiKey = Deno.env.get("GEMINI_API_KEY") ?? "";

  if (!apiKey) return fallbackResponse(tasks);

  const prompt =
    `Eres un asistente de productividad. Reorganiza estas tareas por prioridad cognitiva.\n` +
    `Considera: prioridad (high=3, medium=2, low=1), energía requerida (1-5) y urgencia.\n\n` +
    `Tareas:\n${JSON.stringify(tasks)}\n\n` +
    `Responde SOLO con JSON válido, sin texto adicional, sin markdown:\n` +
    `{"optimized": [<array de tareas reordenadas, mismos objetos>], "explanation": "<motivo breve en español>"}`;

  try {
    const res = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.2, maxOutputTokens: 2048 },
      }),
    });

    if (!res.ok) {
      const errText = await res.text();
      console.error("[optimize-tasks] API error:", res.status, errText);
      return fallbackResponse(tasks);
    }

    const data = await res.json();
    const raw = (data.candidates?.[0]?.content?.parts?.[0]?.text as string ?? "").trim();
    // Limpiar posibles bloques de código markdown
    const cleaned = raw
      .replace(/^```(?:json)?\s*/i, "")
      .replace(/\s*```$/i, "")
      .trim();

    const parsed = JSON.parse(cleaned);
    if (!Array.isArray(parsed.optimized)) throw new Error("Bad format");

    return Response.json(parsed, { headers: corsHeaders });
  } catch (err) {
    console.error("[optimize-tasks] Parse/fetch error:", err);
    return fallbackResponse(tasks);
  }
}

Deno.serve(handler);
