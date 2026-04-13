# Préférences personnelles — Xavier

## Identité & contexte
- Je travaille chez Pretto (courtier en ligne) en tant que Head of technology et architecte de tout les services
- Stack principale : Ruby on Rails, React, Nextjs, Payload CMS (v3), TypeScript, Postgresql, Terraform, AWS
- Outils data : Metabase, BigQuery, Posthog, Graphana
- Environnement : macOS, Conductor.build

## AWS / Infrastructure
- When working with AWS infrastructure
- always verify the correct AWS SSO profile name and working directory before running commands.
- `cd` does not persist across Bash calls - use `cd <dir> && <command>` in a single call.
- When modifying Terraform/CDKTF resources, always scope changes to only the targeted resources using `-target` flags. Never include unrelated changes in a plan/apply without explicit user approval.

## Style de code / Approche
- Ruby : style idiomatique, pas de `self` superflu, favoriser les méthodes de classe lisibles
- TypeScript : strict mode, async/await plutôt que callbacks
- Use proper TypeScript types - never use `unknown` type casts. Ensure database migrations handle existing data (e.g., existing enum columns)
- Nommage en anglais dans le code, commentaires en français si contexte métier complexe
- Pas de trailing summaries après avoir complété une tâche
- Prefer extending existing code over rewriting from scratch. When adding features, build on top of native/existing implementations rather than creating custom solutions. Always ask before taking a custom approach when a native/built-in solution exists.

## Workflow Git
- Branches : `feat/`, `fix/`, `chore/` + description courte
- Commits : conventionnel (feat, fix, refactor…), en anglais
- Ne jamais commiter directement sur `main`
- Commit et ouvre une pull request Github en draft quand tu as terminé
- When starting a new task, use a new branch up to date on origin/master

## Ce que je veux que tu fasses par défaut
- Propose des solutions en Ruby avant d'autres langages
- Favorise la lisibilité sur la concision
- Si tu modifies un fichier existant, dis-moi ce qui change et pourquoi

## Ce que je ne veux pas
- Pas d'explication des concepts que je connais déjà (Ruby, SQL, Git de base)
- Pas de réponses trop verbeuses — aller droit au but

## MCP & outils connectés
- Slack, Notion, BigQuery, Sentry, PostHog, Context7, Serena, AWS disponibles
- Utilise-les si c'est pertinent sans le signaler inutilement
