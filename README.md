# feature-flag-service-env-config

Environment/deployment configuration for the Feature Flag Service, kept separate
from the application source repo (`Feature-Flag-Service`) so that Argo CD can
watch this repo independently. Application code changes never touch this repo;
only deployment-relevant changes do (image tags, replica counts, env config).

Image tags in `api-deployment.yaml` are updated automatically by the app repo's
CI pipeline on every push to `main` — do not edit the image tag manually here,
it will be overwritten by the next CI run.

Secrets are applied imperatively via `kubectl create secret` and are never
stored in this repo — see `secret-template.yaml` for the required shape only.
