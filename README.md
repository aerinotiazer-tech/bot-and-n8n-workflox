# Blind Spot Studio

**Un seul atelier de production : OpenChatCut pour la timeline, Blender pour les plans 3D, OpenCode pour piloter les deux.** La voix off enregistrée par le créateur reste la piste principale; le workflow est prévu pour partir d'un enregistrement brut, sans correction préalable.

## Ce qui est installé

Le projet amont [OpenChatCut](https://github.com/0xsline/OpenChatCut) est épinglé comme sous-module dans [`apps/openchatcut`](apps/openchatcut). Il fournit une vraie timeline multi-pistes, montage conversationnel, captions, motion graphics/WebGL, aperçu et export.

[DCC-MCP Blender](https://github.com/dcc-mcp/dcc-mcp-blender) tourne en mode headless dans le même Codespace. Il apporte le serveur MCP pour créer et rendre des scènes réelles en 3D. L'agent peut insérer les rendus dans le montage OpenChatCut; tu peux revoir et retoucher la timeline dans l'éditeur. Le viewport Blender graphique n'est pas visible dans ce Codespace.

[OpenCode](https://opencode.ai/) relie l'agent aux MCP OpenChatCut et Blender. Le modèle configuré est `groq/qwen/qwen3.8-27b`. Les consignes de montage et de charte sont dans [`AGENTS.md`](AGENTS.md).

## Groq : l'offre gratuite vérifiée

Oui : la documentation actuelle de Groq inclut `qwen/qwen3.8-27b` dans le tableau des limites **Free Plan** : 30 requêtes/minute, 1 000/jour, 8 000 tokens/minute et 200 000/jour. Il s'agit d'un modèle **Preview**, qui peut changer. Sur le plan payant Developer, la fiche affiche 0,80 $/million de tokens entrants et 4,00 $/million sortants; ces prix ne signifient pas que l'utilisation sous le quota Free est facturée. Le niveau actif et les plafonds exacts de ton organisation sont visibles dans Groq Console. [Limites officielles](https://console.groq.com/docs/rate-limits) · [Modèles et tarifs](https://console.groq.com/docs/models) · [Tool use](https://console.groq.com/docs/tool-use)

La transcription utilise Groq `whisper-large-v3-turbo`, avec langue `fr`. La doc Groq inscrit Whisper Turbo dans les limites Free à 20 requêtes/minute, 2 000/jour, 7 200 secondes audio/heure et 28 800/jour. L'upload Free direct est limité à 25 Mo par fichier; le tarif affiché sur le plan Developer est 0,04 $/heure. Le modèle est multilingue et renvoie des timestamps au mot si on les demande. [Speech-to-text Groq](https://console.groq.com/docs/speech-to-text) · [Limites Free](https://console.groq.com/docs/rate-limits)

Les plafonds changent et s'appliquent à l'organisation entière; en cas de quota dépassé, l'API peut renvoyer 429. Le tutoriel explique les limites et le traitement des fichiers trop lourds.

## Démarrer dans Codespaces

1. Ouvre le dépôt dans GitHub Codespaces sur `main`. Si le Codespace existait déjà avant la mise à jour, fais `git pull origin main`, puis **Rebuild Container** pour recharger les paramètres et dépendances.
2. Au premier build, Codespaces installe Node 24, OpenChatCut, Blender 4.5.13, FFmpeg, DCC-MCP et OpenCode. Le téléchargement initial est conséquent.
3. Les services démarrent automatiquement : OpenChatCut sur le port privé 5199, Blender MCP sur le port local 9765. Le secret `GROQ_API_KEY` déjà configuré dans Codespaces est réutilisé par OpenCode et pour la transcription Groq; sa valeur n'est jamais imprimée.
4. Lance `./scripts/run-agent.sh` depuis un terminal Codespaces. Dans l'éditeur, dépose l'enregistrement brut, place-le sur la piste narration, puis demande à l'agent de le transcrire, nettoyer prudemment et monter les visuels.
5. Consulte le guide complet et son prompt prêt à coller dans [`TUTORIEL_VOIX_OFF.md`](TUTORIEL_VOIX_OFF.md). Il couvre les répétitions, les blancs, la vérification de l'ASR, le sound design et les limites de la suppression automatique française.

Commandes utiles :

```bash
bash .devcontainer/start-services.sh  # lancer/relancer les services
./scripts/run-agent.sh                # ouvrir l'agent OpenCode
 tail -f .runtime/openchatcut.log
 tail -f .runtime/blender-mcp.log
```

## Voix off brute et sound design

Le démarrage fixe `PREFERRED_TRANSCRIPTION_PROVIDER=groq`, `GROQ_TRANSCRIPTION_MODEL=whisper-large-v3-turbo` et `TRANSCRIPTION_LANGUAGE=fr`. OpenChatCut dispose de `transcribe_track`, `clean_script` pour le nettoyage mécanique, `read_script` / `apply_script` pour l'édition par le sens, et `browse_library` / `add_audio` pour ajouter des ambiances et SFX. La routine d'agent demande de compresser les blancs manifestement trop longs, de préserver respiration et intention, de repérer les faux départs et phrases répétées par erreur, puis d'écouter les raccords.

Le matching automatique des mots parasites ne garantit pas le français. L'agent doit vérifier lui-même « euh », hésitations et répétitions dans la transcription; il ne doit pas supprimer les mots ambigus par simple ressemblance. L'original est conservé et les coupes restent révisables.

Pour la charte Blind Spot : voix au premier plan, ambiance sombre discrète, quelques whooshes/impacts/ticks aux moments utiles, pas de bruitage permanent. Garde les sons tiers sur une piste séparée et note leur provenance.

## Limites et sécurité

OpenChatCut est encore tôt dans son développement et sous licence AGPL-3.0; Blender et ses rendus utilisent le CPU du Codespace, ce qui peut être lent. Le projet est un atelier assemblé, pas une copie d'After Effects : OpenChatCut apporte la timeline et le motion 2D/WebGL, Blender la vraie 3D.

Le lockfile amont observé avait un avis critique `proxy-addr` avant la version corrective `2.0.8`. Le setup applique un override ciblé dans l'installation locale du sous-module, sans modifier son dépôt amont. L'audit de production relevait encore 17 avis (7 élevés, 10 modérés) dans les dépendances amont après cette correction; le port de l'éditeur est privé et le port Blender MCP n'est pas forwardé. N'exécute pas `npm audit fix --force` aveuglément.

Les médias et exports sont ignorés par Git par défaut. Enregistre les livrables à récupérer dans `projects/<episode>/exports/`. Le détail des secrets et des commandes est dans le tutoriel.
