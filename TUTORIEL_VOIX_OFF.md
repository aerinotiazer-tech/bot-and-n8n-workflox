# Tutoriel Blind Spot — de la voix off brute au premier montage

Tu peux déposer ton enregistrement tel quel, juste après la prise. **Ne le corrige pas avant.** Le Codespace est configuré pour donner à la fois à OpenCode et à OpenChatCut accès à la même variable secrète `GROQ_API_KEY`. Au démarrage d'OpenChatCut, les valeurs par défaut demandées sont Groq pour la transcription, Whisper Large V3 Turbo et le français. Le fichier original reste intact; les coupes se font dans le projet de montage.

## Groq : modèles gratuits et limites réelles

Au 20 octobre 2026, le tableau Groq des limites Free indique pour `qwen/qwen3.8-27b` **30 requêtes/minute, 1 000 requêtes/jour, 8 000 tokens/minute et 200 000 tokens/jour**. C'est bien le modèle configuré pour l'agent et il prend en charge l'appel d'outils local/distants ainsi que les appels parallèles. Il est toutefois classé **Preview**, donc il peut changer ou être retiré. La page Supported Models affiche aussi son tarif Developer de 0,80 $/million de tokens entrants et 4,00 $/million sortants : ces prix ne sont pas une promesse que le modèle est gratuit sans limite. Reste sur le plan Free et surveille les limites exactes de ton organisation dans Groq Console. Si tu as volontairement activé Developer/Pay-as-you-go, vérifie les paramètres de facturation avant tout usage soutenu. [1] [2]

Groq offre aussi Whisper Large V3 Turbo pour la transcription multilingue. Les limites Free publiées sont **20 requêtes/minute, 2 000 requêtes/jour, 7 200 secondes audio/heure et 28 800 secondes/jour** (soit 2 h de traitement par heure, jusqu'à 8 h par jour si les quotas sont disponibles). La limite de taille documentée pour un envoi direct en Free est **25 Mo par fichier**. La transcription peut rendre du JSON horodaté au niveau segment ou mot. Le tarif affiché sur la page des modèles est 0,04 $/heure dans le contexte Developer; les plafonds Free et le tarif Developer sont deux informations distinctes. [1] [3]

Les limites s'appliquent à l'organisation Groq et peuvent être différentes selon son compte; la page **Limits** de la Console donne les valeurs exactes. En Free, une limite atteinte bloque les nouvelles requêtes et renvoie 429; le passage au plan Developer et à la facturation demande une démarche séparée et un moyen de paiement. N'active pas ce plan pour résoudre un quota sans le décider. [1] [6]

Si Qwen quitte Preview ou perd l'accès au plan Free, `openai/gpt-oss-20b` est une option de secours : Groq l'inscrit aussi aux limites Free de 30 RPM, 1 000 RPD, 8 000 TPM et 200 000 TPD. Groq documente son tool use, mais pas les appels d'outils parallèles pour ce modèle; l'agent peut donc être moins rapide pour enchaîner les opérations. Pour le choisir, remplace dans `.opencode/opencode.json` `groq/qwen/qwen3.8-27b` par `groq/openai/gpt-oss-20b`. [1] [2]

## Première mise en route dans Codespaces

1. Ouvre le dépôt [`bot-and-n8n-workflox`](https://github.com/aerinotiazer-tech/bot-and-n8n-workflox) dans Codespaces et choisis `main`. Si le Codespace a été créé avant la dernière mise à jour, lance `git pull origin main`, puis demande **Rebuild Container** afin que les réglages de démarrage du conteneur soient rechargés.
2. Attends l'ouverture d'OpenChatCut sur le port privé 5199. Le serveur Blender MCP reste local au Codespace. Ouvre un terminal, lance `./scripts/run-agent.sh`, puis vérifie qu'OpenCode indique le modèle `groq/qwen/qwen3.8-27b` et les connexions MCP `openchatcut` et `blender`.
3. À l'import, le réglage Groq vient de la variable `GROQ_API_KEY` que tu as déjà ajoutée aux secrets Codespaces. La valeur n'est jamais affichée par les scripts. Dans les réglages de transcription d'OpenChatCut, confirme que Groq est sélectionné et que l'état de la clé est « configured ». Le modèle audio par défaut est `whisper-large-v3-turbo`, la langue `fr`.
4. Crée ou ouvre le projet de l'épisode. Dépose l'enregistrement brut dans la bibliothèque média d'OpenChatCut, puis place-le sur la piste narration (A1 par défaut). Si tu as une vidéo face caméra, importe-la séparément; la transcription doit correspondre au fichier dont tu veux couper l'audio.
5. Demande à l'agent de transcrire le clip en français avec horodatages mot à mot. L'import seul ne garantit pas que la transcription est terminée : attends son état « ready » avant de demander le nettoyage. Si le fichier dépasse 25 Mo, ne le redépose pas en boucle : dis-le à l'agent. Il peut vérifier la taille et tenter une copie FLAC mono à 16 kHz; si elle reste trop lourde, il faudra la couper en morceaux avec un léger chevauchement, puis vérifier le raccord entre eux.

## Nettoyage de l'oral — mécanique d'abord, sens ensuite

OpenChatCut a une vraie timeline éditable à partir du transcript : les coupes de mots/phrases s'appliquent à l'audio lu, elles ne changent pas le fichier source. Le guide amont recommande deux passes : nettoyage mécanique des fillers reconnus et pauses, puis édition éditoriale du script de timeline. Il précise que `clean_script` n'est pas destiné aux phrases répétées ou aux reprises qui demandent de comprendre le sens. [4]

Demande à l'agent de suivre cette séquence :

- Lire la transcription et confirmer que les noms propres, termes tech, chiffres et négations sont correctement reconnus; corriger les erreurs ASR avant de couper.
- Faire une première passe prudente des longues pauses avec `clean_script`. Garde en général 0,3 à 0,5 seconde entre phrases; compresse les grands blancs qui n'ont pas de valeur dramatique. Conserve les souffles naturels et les pauses qui appuient une révélation. N'applique pas un « cut silence » agressif sur chaque respiration.
- Relire ensuite la version de timeline fraîchement générée. Retirer les faux départs, débuts de phrase abandonnés et prises répétées par erreur. Quand une phrase a plusieurs prises, garde la plus claire et la plus naturelle. Ne coupe pas une répétition volontaire, une insistance (« très, très important »), une punchline ou un effet de rythme.
- Vérifier autour de chaque jonction que le mot qui précède et celui qui suit restent intacts et que la phrase est encore logique. Puis écouter le début, les transitions et les coupes importantes dans OpenChatCut.

**Prudence pour le français :** la documentation de nettoyage automatique citée par OpenChatCut nomme notamment `um`, `uh`, `er`, `ah` et des exemples chinois; elle ne garantit pas la suppression universelle de « euh », « heu », « ben » ou de tous les faux départs français. Ne suppose pas que `clean_script` va tous les trouver. L'agent doit les repérer dans le transcript et les couper par l'édition de script, puis te signaler les cas ambigus. Un mot comme « enfin » peut être un vrai connecteur et ne doit pas disparaître sur simple correspondance. [4]

## Sound design Blind Spot

Une fois le montage vocal propre, demande une passe de sound design distincte. Commence par la voix : pas de musique ni de SFX qui masque les consonnes. Dans OpenChatCut, l'agent peut explorer `browse_library` pour `sound-effects` et `audio-fx`, placer les éléments choisis sur une piste audio séparée avec `add_audio`, et ajuster les propriétés du clip avec `edit_item`. [5]

Pour Blind Spot, demande une ambiance sombre et discrète sous l'ouverture ou les passages de tension, puis des sons ponctuels seulement quand ils ont une fonction : whoosh sur un vrai mouvement caméra, petit tick sur un jalon, impact grave au moment d'une révélation, courte montée avant un changement de chapitre, puis silence ou audio cut avant une phrase importante. Fais des fondus courts et vérifie chaque raccord à l'écoute. Évite un bruitage à chaque coupe ou une musique trop forte en continu. Note les sources/licences des sons ajoutés; si la bibliothèque ne contient pas de son adapté, demande-moi de fournir un asset plutôt que d'inventer sa provenance.

## Prompt prêt à coller dans OpenCode

```text
Je viens de déposer ma voix off brute dans le projet. Ne me demande pas de la corriger ou de la réenregistrer. Vérifie la transcription Groq en français avec horodatages, puis corrige les erreurs de reconnaissance évidentes sans toucher au son source. Fais un nettoyage prudent des longues pauses et des hésitations évidentes. Ensuite relis le script de timeline et coupe les faux départs et phrases répétées par erreur en gardant la prise la plus claire; préserve les répétitions intentionnelles, les respirations normales, l'emphase, le sens, les noms propres, les chiffres et les termes techniques. Applique les changements au montage et vérifie les jonctions en écoutant l'aperçu. Si un segment est ambigu, ne le supprime pas : marque-le et demande-moi. Après cette passe, construis les visuels au rythme de la voix et ajoute un sound design Blind Spot sobre sur une piste séparée : voix toujours intelligible, ambiance discrète, quelques effets seulement aux moments narrativement justifiés. Utilise la vraie 3D Blender MCP pour les plans qui le méritent. Garde le fichier audio brut et le projet éditable; ne génère pas de voix de remplacement. À la fin, résume les coupes effectuées, les segments à valider et les éventuels sons dont la licence/source reste à confirmer.
```

Si l'agent signale que la transcription est en erreur, qu'un mot français a été mal détecté ou que Groq renvoie 429/limite de taille, arrête cette partie et demande-lui de décrire le blocage sans supprimer le média. Tu peux ensuite m'appeler avec le message d'erreur ou le segment concerné.

## Références

[1]: https://console.groq.com/docs/rate-limits "Groq Rate Limits et tableaux Free Plan"
[2]: https://console.groq.com/docs/models "Groq Supported Models, tarifs et statuts"
[3]: https://console.groq.com/docs/speech-to-text "Groq Speech to Text, Whisper et limites audio"
[4]: https://github.com/0xsline/OpenChatCut/blob/7995b3c/src/agent/skills/transcription/SKILL.md "Guide de transcription OpenChatCut épinglé dans le studio"
[5]: https://github.com/0xsline/OpenChatCut/blob/7995b3c/src/agent/tools/schemas/library-tools.ts "Bibliothèque audio et outils OpenChatCut"
[6]: https://console.groq.com/docs/billing-faqs "Groq Billing FAQs sur le passage à Developer et la facturation"
[6]: https://console.groq.com/docs/billing-faqs "Groq Billing FAQs sur le passage à Developer et la facturation"
