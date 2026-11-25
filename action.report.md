# Report delle GitHub Actions in `.github.old`

Questo report riassume le action referenziate nei workflow sotto [`.github.old/workflows`](./.github.old/workflows). GitHub Actions carica automaticamente i workflow da `.github/workflows`, non da `.github.old/workflows`: questi file, nella posizione attuale, sono quindi una copia d'archivio e non vengono eseguiti automaticamente.

## Action e funzioni

| Action | Workflow | Scopo |
| --- | --- | --- |
| `actions/checkout` | [`test.yml`](./.github.old/workflows/test.yml), [`lint.yml`](./.github.old/workflows/lint.yml), [`crowdin.yml`](./.github.old/workflows/crowdin.yml), [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml), [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Scarica il repository nel runner, così i passaggi successivi possono accedere ai file. |
| `pnpm/action-setup` | [`test.yml`](./.github.old/workflows/test.yml), [`lint.yml`](./.github.old/workflows/lint.yml), [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Installa pnpm; usata dai workflow JavaScript/Node. |
| `actions/setup-node` | [`test.yml`](./.github.old/workflows/test.yml), [`lint.yml`](./.github.old/workflows/lint.yml), [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Configura Node.js e, dove richiesto, la cache pnpm. |
| `actions/setup-python` | [`lint.yml`](./.github.old/workflows/lint.yml), [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml) | Configura Python per i controlli e la build della documentazione. |
| `astral-sh/setup-uv` | [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml) | Installa `uv`, usato per gestire l'ambiente e l'esecuzione dei comandi Python della documentazione. |
| `pre-commit/action` | [`lint.yml`](./.github.old/workflows/lint.yml) | Esegue gli hook definiti nella configurazione pre-commit del progetto. |
| `actions/cache` | [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Salva e ripristina `.next/cache` per ridurre i tempi di build Next.js. |
| `awalsh128/cache-apt-pkgs-action` | [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml) | Installa e mette in cache pacchetti APT; qui installa `pngquant` per le immagini della documentazione. |
| `codecov/codecov-action` | [`test.yml`](./.github.old/workflows/test.yml) | Carica su Codecov il report di coverage generato dai test Vitest. |
| `actions/github-script` | [`pr-triage.yml`](./.github.old/workflows/pr-triage.yml), [`issue-triage.yml`](./.github.old/workflows/issue-triage.yml), [`repo-maintenance.yml`](./.github.old/workflows/repo-maintenance.yml) | Esegue JavaScript inline con accesso alle API GitHub REST e GraphQL; gli script del repository commentano, chiudono o bloccano issue, PR e discussioni. |
| `peakoss/anti-slop` | [`pr-quality.yml`](./.github.old/workflows/pr-quality.yml) | Applica controlli automatici alle PR, come la presenza del template e termini bloccati; qui può aggiungere un'etichetta o chiudere una PR secondo le regole configurate. |
| `crowdin/github-action` | [`crowdin.yml`](./.github.old/workflows/crowdin.yml) | Sincronizza le traduzioni con Crowdin; il workflow scarica le traduzioni e le porta nel branch di localizzazione. |
| `dessant/reaction-comments` | [`reaction-comments.yml`](./.github.old/workflows/reaction-comments.yml) | Gestisce reazioni ai commenti di issue e PR. |
| `release-drafter/release-drafter` | [`release-drafter.yml`](./.github.old/workflows/release-drafter.yml) | Crea o aggiorna una bozza di release, eventualmente usando una versione specificata manualmente. |
| `release-drafter/release-drafter/autolabeler` | [`release-drafter.yml`](./.github.old/workflows/release-drafter.yml) | Assegna etichette automatiche alle PR in base alle regole di Release Drafter. |
| `actions/stale` | [`repo-maintenance.yml`](./.github.old/workflows/repo-maintenance.yml) | Marca issue e PR inattive come stale e può chiuderle dopo il periodo configurato. Qui la soglia è 7 giorni per diventare stale e 14 per la chiusura. |
| `dessant/lock-threads` | [`repo-maintenance.yml`](./.github.old/workflows/repo-maintenance.yml) | Blocca issue, PR e discussioni chiuse rimaste inattive; qui la soglia è 30 giorni. |
| `actions/configure-pages` | [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml) | Prepara il job per la pubblicazione su GitHub Pages. |
| `actions/upload-pages-artifact` | [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml) | Carica come artifact il sito generato, qui dalla cartella `site`. |
| `actions/deploy-pages` | [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml) | Pubblica su GitHub Pages l'artifact caricato. |
| `docker/metadata-action` | [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Calcola tag e metadati OCI dell'immagine, in base a branch, tag o pianificazione. |
| `docker/login-action` | [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Esegue l'autenticazione ai registry Docker, qui GHCR e Docker Hub. |
| `docker/setup-qemu-action` | [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Configura QEMU per consentire build multi-arch, ad esempio ARM su runner x86. |
| `docker/setup-buildx-action` | [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Configura Docker Buildx, il builder basato su BuildKit. |
| `docker/build-push-action` | [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Costruisce l'immagine Docker e la pubblica quando l'evento lo consente. |

## Requisiti e configurazione specifica

I dettagli sotto descrivono come le action sono configurate in questi workflow; non sono necessariamente tutti i requisiti generali del progetto upstream dell'action. I secrets nominati devono essere configurati nelle impostazioni del repository o dell'organizzazione GitHub.

### Setup, test e lint

- **`actions/checkout`** — non passa input `with`; usa il token automatico di GitHub Actions. Il workflow deve concedere accesso al contenuto del repository.
- **`pnpm/action-setup`** — versione 9 in `test.yml`; versione 10 in `lint.yml` e `docker-publish.yml`. In lint e docker install automatico disabilitato con `run_install: false`.
- **`actions/setup-node`** — usa Node.js 24 e `cache: pnpm`; richiede il lockfile pnpm per calcolare la cache.
- **`actions/setup-python`** — `3.x` in lint; legge `.python-version` nella build della documentazione.
- **`astral-sh/setup-uv`** — nessun input specificato; il workflow esegue `uv run --frozen`, quindi si basa sui file di progetto e lockfile uv.
- **`pre-commit/action`** — nessun input specificato; esegue la configurazione pre-commit del repository. Python viene configurato nel passaggio precedente.
- **`actions/cache`** — salva `.next/cache`; chiave derivata da sistema operativo, `pnpm-lock.yaml` e file JS/JSX; usa una chiave di ripristino più generica per riutilizzare cache precedenti.
- **`awalsh128/cache-apt-pkgs-action`** — installa `pngquant` e usa `version: "1.0"` come chiave/versione della cache APT.
- **`codecov/codecov-action`** — richiede il secret `CODECOV_TOKEN`; carica `./coverage/lcov.info`, assegna nome e flag allo shard Vitest e fallisce la CI se l'upload fallisce (`fail_ci_if_error: true`).

### API GitHub, issue e pull request

- **`actions/github-script`** — non dichiara un secret personalizzato: usa il `GITHUB_TOKEN` fornito da GitHub Actions. Servono permessi coerenti con le API chiamate: `pull-requests: write` per il triage PR, `issues: write` per le issue e `discussions: write` per le discussioni e la manutenzione.
- **`peakoss/anti-slop`** — esegue su PR aperte o riaperte; richiede il template PR, consente la sezione facoltativa `Checklist:`, blocca il termine configurato, imposta `max-failures: 4` e può aggiungere l'etichetta `ai`. Il job ha `pull-requests: write`.
- **`dessant/reaction-comments`** — si attiva su commenti creati o modificati in issue e review PR; non ha input `with` espliciti. Il job concede `actions: write`, `issues: write` e `pull-requests: write`.
- **`actions/stale`** — marca stale dopo 7 giorni e chiude dopo 14; usa l'etichetta `stale` per issue e PR. Il job richiede `issues: write` e `pull-requests: write`.
- **`dessant/lock-threads`** — soglia di inattività di 30 giorni per issue, PR e discussioni; pubblica i messaggi configurati e abilita `log-output`. Il job richiede permessi di scrittura su issue, PR e discussioni.

### Traduzioni e release

- **`crowdin/github-action`** — richiede i secrets `CROWDIN_PROJECT_ID` e `CROWDIN_PERSONAL_TOKEN`, oltre al `GITHUB_TOKEN`. Scarica, ma non carica, traduzioni; usa i branch `dev` e `l10n_dev` e assegna l'etichetta `translation` alle PR. Il workflow richiede `contents: write` e `pull-requests: write`.
- **`release-drafter/release-drafter`** — usa `config-name: release-drafter.yml` e il secret automatico `GITHUB_TOKEN`; richiede `contents: write` e `pull-requests: read`. L'input manuale `version` è facoltativo.
- **`release-drafter/release-drafter/autolabeler`** — usa la stessa configurazione `release-drafter.yml` e `GITHUB_TOKEN`; il job richiede `pull-requests: write`.

### Pubblicazione documentazione

- **`actions/configure-pages`** — nessun input esplicito; è nel job di deploy, che richiede `pages: write` e `id-token: write`.
- **`actions/upload-pages-artifact`** — carica la directory `site`; il job deve aver generato prima il sito.
- **`actions/deploy-pages`** — pubblica l'artifact Pages caricato nel passaggio precedente; usa l'ambiente `github-pages`. Non è configurato un secret personale: la pubblicazione usa il permesso `id-token: write`.
- La pubblicazione richiede inoltre GitHub Pages abilitato e l'ambiente `github-pages` disponibile nel repository.

### Pubblicazione immagini Docker

- **`docker/metadata-action`** — prende come immagini `${{ github.repository }}` e `ghcr.io/${{ github.repository }}`; crea tag per schedule (`nightly`), branch, tag Git e versioni semver, più il tag `latest` quando applicabile.
- **`docker/login-action`** — per GHCR usa `${{ github.actor }}` e `GITHUB_TOKEN`; per Docker Hub richiede i secrets `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`. I login sono saltati nelle pull request. Il job richiede `packages: write`.
- **`docker/setup-qemu-action`** — nessun input esplicito; prepara l'emulazione usata dalla build multi-arch.
- **`docker/setup-buildx-action`** — nessun input esplicito; prepara il builder Buildx usato dalla successiva build.
- **`docker/build-push-action`** — usa `context: .`; pubblica solo fuori dalle pull request; riceve tag e label dalla metadata action; costruisce `linux/amd64` e `linux/arm64`. Passa gli argomenti `CI=true`, `BUILDTIME`, `VERSION` e `REVISION`; disabilita provenance e usa cache Buildx locale. Per pubblicare, il workflow deve autenticarsi ai registry prima di questo passaggio.

## Workflow e combinazioni di action

| Workflow | Cosa fa |
| --- | --- |
| [`test.yml`](./.github.old/workflows/test.yml) | Esegue Vitest in quattro shard e carica i report di coverage su Codecov. |
| [`lint.yml`](./.github.old/workflows/lint.yml) | Esegue pre-commit e il lint frontend; configura Python, Node.js e pnpm. |
| [`docker-publish.yml`](./.github.old/workflows/docker-publish.yml) | Compila l'app, prepara metadati e cache, configura Buildx/QEMU, quindi costruisce immagini multi-arch e le pubblica nei registry. |
| [`docs-publish.yml`](./.github.old/workflows/docs-publish.yml) | Verifica la build della documentazione nelle PR e pubblica il sito su GitHub Pages dal branch `main`. |
| [`crowdin.yml`](./.github.old/workflows/crowdin.yml) | Sincronizza le traduzioni con Crowdin e usa un branch dedicato alla localizzazione. |
| [`release-drafter.yml`](./.github.old/workflows/release-drafter.yml) | Aggiorna le bozze di release e applica etichette automatiche alle PR. |
| [`pr-quality.yml`](./.github.old/workflows/pr-quality.yml) | Esegue i controlli automatici configurati per la qualità delle PR. |
| [`pr-triage.yml`](./.github.old/workflows/pr-triage.yml) | Quando una PR riceve l'etichetta `needs-requirements`, pubblica un commento e la chiude. |
| [`issue-triage.yml`](./.github.old/workflows/issue-triage.yml) | Gestisce issue e discussioni etichettate, aggiungendo commenti e applicando le azioni previste dallo script. |
| [`repo-maintenance.yml`](./.github.old/workflows/repo-maintenance.yml) | Gestisce thread stale o inattivi e chiude automaticamente alcune discussioni secondo soglie e criteri configurati. |
| [`reaction-comments.yml`](./.github.old/workflows/reaction-comments.yml) | Si attiva quando vengono creati o modificati commenti su issue e PR e gestisce le relative reazioni. |

## Note pratiche

- I workflow referenziano le action tramite hash di commit, con un commento che spesso indica anche la versione. Il pinning a un commit rende il riferimento più stabile di un tag mobile come `@v1`.
- Le action che modificano issue, PR o discussioni richiedono permessi GitHub espliciti. Conviene concedere solo i permessi necessari al singolo job.
- `actions/github-script` non definisce da sola la policy: la logica effettiva è il codice JavaScript passato nel campo `script`.
- Le action non sono comandi locali: vengono eseguite dal runner GitHub durante il workflow e possono configurare strumenti, chiamare API o produrre artifact.
