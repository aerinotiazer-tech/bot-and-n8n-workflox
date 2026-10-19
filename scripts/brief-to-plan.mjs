if (!process.env.GROQ_API_KEY) {
  console.error('GROQ_API_KEY manquant. Configure-le dans les secrets Codespaces; ne le colle pas dans le code.');
  process.exit(1);
}

const brief = process.argv.slice(2).join(' ').trim();
if (!brief) {
  console.error('Usage: npm run plan -- "brief, script ou repères de voix off"');
  process.exit(1);
}
if (!process.env.GROQ_MODEL) {
  console.error('GROQ_MODEL manquant. Choisis un modèle actuellement disponible dans ton compte Groq et configure-le comme variable Codespaces.');
  process.exit(1);
}

const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
  method: 'POST',
  headers: {
    authorization: `Bearer ${process.env.GROQ_API_KEY}`,
    'content-type': 'application/json',
  },
  body: JSON.stringify({
    model: process.env.GROQ_MODEL,
    temperature: 0.35,
    messages: [
      {role: 'system', content: 'Tu es assistant de préproduction motion design pour Blind Spot. L’utilisateur enregistre lui-même la voix off : ne jamais en écrire ni en synthétiser. À partir du brief fourni, retourne uniquement un JSON valide avec un tableau scenes. Chaque scène contient narration_ref, duree_estimee_s, intention, visuel, mouvement_camera, animation_secondaire, accent, transition, assets_a_fournir. Style : noir #000000/#0D0D0D, blanc et rouge #FF0000 seulement pour les accents critiques; mouvement documentaire cinématographique, jamais décoratif. Ne fabrique aucun fait.'},
      {role: 'user', content: brief},
    ],
  }),
});

if (!response.ok) {
  const message = await response.text();
  throw new Error(`Groq API ${response.status}: ${message}`);
}
const result = await response.json();
const text = result.choices?.[0]?.message?.content?.trim();
if (!text) throw new Error('Le fournisseur n’a renvoyé aucun plan.');
const normalized = text.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
const plan = JSON.parse(normalized);
process.stdout.write(`${JSON.stringify(plan, null, 2)}\n`);
