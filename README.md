# Blind Spot Studio

**OpenChatCut est l'éditeur principal; Blender fournit les plans 3D; OpenCode relie les deux avec Groq.** Le Codespace installe l'application de montage, un Blender sans interface graphique pour la production automatisée, FFmpeg et l'agent MCP. La voix off reste celle du créateur.

## Ce qui remplace l'ancien prototype

Le premier prototype Remotion personnalisé a été retiré. L'application centrale est maintenant le dépôt amont [OpenChatCut](https://github.com/0xsline/OpenChatCut), épinglé comme sous-module dans [`apps/openchatcut`](apps/openchatcut). Il fournit une vraie timeline multi-pistes, montage conversationnel, titres, transitions, captions, motion graphics/WebGL, aperçu et export.

[DCC-MCP Blender](https://github.com/dcc-mcp/dcc-mcp-blender) tourne à côté, en mode headless, dans le même Codespace. Son serveur MCP permet à l'agent de créer/modifier des scènes Blender, animer caméra et objets, faire des rendus et produire des plans réellement 3D. Les plans rendus sont ensuite importés dans OpenChatCut pour constituer le montage final.

[OpenCode](https://opencode.ai/) est le seul agent de coordination. Sa configuration relie simultanément le MCP OpenChatCut et le MCP Blender. Le modèle Groq configuré est `qwen/qwen3.8-27b`, validé comme identifiant par OpenCode et choisi pour sa capacité de tool use. La fiche Groq actuelle ne documente pas explicitement l’envoi d’images pour ce modèle : ne compte pas sur l’inspection visuelle automatique des rendus. Tu peux fournir les retours à l’agent sous forme de notes; change vers un modèle Groq vision uniquement après avoir vérifié qu’il accepte aussi les outils MCP. Les consignes Blind Spot et les règles de montage sont dans [`AGENTS.md`](AGENTS.md).

> **Coût Groq :** le catalogue consulté affiche `qwen/qwen3.8-27b` à 0,80 $/million de tokens d'entrée et 4,00 $/million de tokens de sortie. Ce n'est donc pas un modèle gratuit. Pour utiliser un autre modèle, change `model` dans `.opencode/opencode.json` après avoir vérifié qu'il supporte les outils MCP. Pour analyser des images, vérifie explicitement le support vision dans la fiche officielle du modèle. Les tarifs et identifiants changent; vérifie le catalogue Groq avant un projet long.

## Démarrer

1. Ouvre le dépôt dans **GitHub Codespaces**. Le conteneur utilise Node.js 24 requis par OpenChatCut, Blender 4.5.13 téléchargé depuis le site Blender avec vérification SHA-256, et FFmpeg.
2. Le premier post-création initialise le sous-module, installe les dépendances OpenChatCut sans le paquet CUDA optionnel et installe DCC-MCP dans le Python embarqué de Blender. Ce téléchargement est plus lourd qu'un simple starter, mais prépare le vrai pipeline.
3. Ajoute `GROQ_API_KEY` dans **Settings → Codespaces → Secrets** du dépôt, si ce n'est pas déjà fait. Le code ne contient pas la clé. Le modèle est déjà indiqué dans `.opencode/opencode.json`.
4. À l'ouverture du Codespace, les services démarrent automatiquement. OpenChatCut est servi sur le port 5199 et s'ouvre dans le navigateur; le port Blender MCP 9765 reste local au Codespace.
5. Dans un terminal Codespaces, lance `./scripts/run-agent.sh`. Demande par exemple : *« Crée le projet d'épisode à partir de ma voix off et de mon script; respecte les jalons; utilise OpenChatCut pour le montage et Blender MCP pour les plans nécessitant une vraie 3D. Ne remplace pas ma voix. »*
6. Reviens dans OpenChatCut pour inspecter, retoucher la timeline, ajuster les coupes et exporter. Enregistre les exports à récupérer dans `projects/<episode>/exports/` (les médias et exports sont ignorés par Git).

Commandes utiles :

```bash
# Lancer ou relancer OpenChatCut et Blender MCP
bash .devcontainer/start-services.sh

# Voir les journaux
 tail -f .runtime/openchatcut.log
 tail -f .runtime/blender-mcp.log

# Démarrer l'agent Groq/OpenCode
./scripts/run-agent.sh
```

## Codespaces secrets et configuration

- `GROQ_API_KEY` est lu depuis l'environnement Codespaces par OpenCode via `{env:GROQ_API_KEY}`. Ne le mets pas dans `.env`, un fichier versionné, le sous-module ou un prompt.
- Un jeton local `OPENCHATCUT_MCP_TOKEN` est généré avec des permissions restreintes dans `~/.config/blindspot/`; il authentifie la connexion locale d'OpenCode à OpenChatCut. Il ne quitte pas le Codespace et n'est pas versionné.
- Le serveur Blender MCP écoute sur `127.0.0.1:9765`; il n'est pas publié par le forwarding Codespaces. Le navigateur n'accède qu'à l'interface OpenChatCut sur 5199.
- Les projets/media d'OpenChatCut résident dans son profil de développement local sous `~/.openchatcut/dev-profiles/`, pas dans Git. Les fichiers téléchargés/exportés doivent être enregistrés dans `projects/` pour être facilement récupérés depuis le workspace. Les médias sont ignorés par Git par défaut.

## Validation et limites honnêtes

Le dépôt amont OpenChatCut est un éditeur tôt dans son développement (Node 24, licence AGPL-3.0); le sous-module est volontairement épinglé à un commit précis. DCC-MCP Blender est un projet distinct (MIT) avec tests headless sur Blender 4.5.13 et 5.2.1. Le Codespace utilise sa voie headless : l'agent peut construire et rendre des scènes, mais **tu ne vois pas le viewport Blender live**. Tu prévisualises le rendu dans OpenChatCut et fais tes retouches dans sa timeline. Le rendu Blender et les exports vidéo peuvent être lents en CPU; un Codespace sans GPU n'est pas un poste de rendu final accéléré.

Ce n'est pas une copie de l'interface After Effects : OpenChatCut fournit le montage/motion 2D-WebGL, Blender apporte la vraie 3D, et les deux restent éditables dans leur outil respectif. Les projets Blender (`.blend`) et les assets intermédiaires doivent être explicitement enregistrés dans le dossier de l'épisode.

## Sources amont

- [OpenChatCut — dépôt, installation, MCP externe, fonctionnalités et licence](https://github.com/0xsline/OpenChatCut)
- [DCC-MCP Blender — MCP headless, API typée, versions Blender testées et licence](https://github.com/dcc-mcp/dcc-mcp-blender)
- [OpenCode — fournisseurs, Groq et serveurs MCP](https://opencode.ai/docs/mcp-servers/)
- [Modèles Groq](https://console.groq.com/docs/models) et [vision + tool use](https://console.groq.com/docs/vision)
- [Codespaces — documentation](https://docs.github.com/en/codespaces/overview)


## Note de sécurité npm

Le lockfile amont observé pendant l'intégration résolvait `proxy-addr` sous la version corrective `2.0.8` (avis critique GHSA-jqcg-44mw-7w3h). Le setup Codespaces ajoute un override local vers `2.0.8`, puis réinstalle et vérifie cette version; le source amont et le lockfile du sous-module ne sont pas commités comme fork. Après ce correctif, l'audit de production npm signale encore **17 avis** (7 élevés, 10 modérés) dans les dépendances amont. Pour limiter l'exposition, le port de l'éditeur est privé et le port du serveur Blender MCP n'est jamais forwardé. Ne rends pas le port 5199 public. Refaire `npm audit` au fil des mises à jour du dépôt OpenChatCut et n'appliquer aucun `npm audit fix --force` aveuglément.
