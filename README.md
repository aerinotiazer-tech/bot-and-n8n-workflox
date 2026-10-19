# Blind Spot — Motion Studio

Socle de production YouTube : **Remotion** pour les graphiques et le motion design, **Blender** pour les scènes 3D, **FFmpeg** pour les opérations vidéo et **Groq** facultatif pour transformer un brief/script en plan de séquences. La voix off est enregistrée par le créateur et doit être fournie comme média de montage; aucune narration IA n'est générée.

## Démarrer dans GitHub Codespaces

Dans GitHub, ouvrir ce dépôt, choisir **Code → Codespaces → Create codespace on main**. Le conteneur installe Node.js, Blender et FFmpeg. Après la création :

```bash
npm run studio
```

Le port 3000 ouvre Remotion Studio. La composition exemple est dans `src/scenes/BlindSpotEpisode.tsx`; remplace les titres et crée des scènes supplémentaires plutôt que de modifier les sources originales.

## Générer un rendu

```bash
npm run render:preview
npm run render
```

Les fichiers sont créés dans `out/` (ignoré par Git). Pour inspecter une vidéo : `ffprobe -hide_banner out/blindspot.mp4`.

## Blender

Le fichier `blender/scene_template.py` illustre une scène avec caméra parentée à un Empty qui joue le rôle d'un null/contrôleur. Pour lancer Blender sans interface :

```bash
blender -b -P blender/scene_template.py
```

Ce modèle est un point de départ, pas une scène finale. Pour exporter une animation, configurer les options de rendu puis appeler Blender avec `-a`; convertir/assembler ensuite les séquences rendues avec FFmpeg. Les rendus 3D peuvent être lents en Codespaces, qui ne fournit pas un workflow de prévisualisation GPU de station de travail.

## Plan de montage facultatif avec Groq

Configurer `GROQ_API_KEY` comme **secret Codespaces** dans les paramètres du dépôt, puis `GROQ_MODEL` comme variable Codespaces en choisissant un identifiant de modèle actuellement disponible dans ton compte. Les modèles, tarifs et quotas peuvent évoluer; ne pars pas du principe qu'un modèle est gratuit sans vérifier les conditions affichées par Groq. Ne place jamais la clé dans un fichier, un commit ou une commande conservée dans l'historique.

Le plan de séquences s'obtient avec :

```bash
npm run plan -- "[brief, script ou repères de la voix off]"
```

La commande renvoie une proposition JSON; elle ne modifie pas automatiquement la vidéo et ne génère pas de voix off. Vérifie les références à la narration et les durées estimées, puis ajuste-les après écoute de ton enregistrement.

## Principes Blind Spot

Voir [AGENTS.md](AGENTS.md) pour la charte de production : noirs profonds, blanc, rouge `#FF0000` réservé aux accents, mouvement cinématographique motivé par le récit, lisibilité et validation humaine avant le rendu final. Ne jamais publier automatiquement.

## Coûts et licences

Codespaces peut consommer des quotas d'heures et de stockage selon ton compte. Groq a ses propres limites et conditions d'utilisation; vérifie les tarifs/quota applicables avant un usage soutenu. Remotion possède des conditions de licence distinctes selon l'utilisateur et l'organisation; consulte [sa licence](https://www.remotion.dev/license). Blender et FFmpeg ont aussi leurs licences propres.
