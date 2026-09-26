# feature-flag-service-env-config

GitOps source of truth for the ff-idp EKS cluster. Argo CD watches this repo; nothing is
applied by hand.

```
platform/
  argocd-apps/      App-of-apps: the root Application (created by ff-idp-infra/40-platform)
                    syncs every Application in here.
    platform-cluster.yaml   wave 0 -> platform/cluster
    feature-flag-dev.yaml   wave 1 -> apps/idp-portal/          Backstage. Image from github.com/DSurya11/idp-portal CI.
apps/feature-flag-service/overlays/dev
    idp-portal.yaml         wave 1 -> apps/idp-portal/overlays/dev (Backstage, port-forward only)
  cluster/          ClusterSecretStore (ESO -> AWS Secrets Manager, via IRSA)
  kyverno/          Policies. NOT synced until Kyverno is installed (Step 33).
apps/feature-flag-service/
  base/             Deployment, Service, Ingress, ExternalSecret, migration Job
  overlays/dev/     DEPLOYED, automated sync. CI updates newTag here.
  overlays/staging/ Defined, not deployed.
  overlays/prod/    Defined, not deployed. Manual sync when enabled. PDB minAvailable 2.
```

No `kind: Secret` lives in this repo: ESO creates `feature-flag-secrets` at runtime from
AWS Secrets Manager (`ff-idp/db-creds`, `ff-idp/jwt-secret`, `ff-idp/valkey`).

Render locally: `kubectl kustomize apps/feature-flag-service/overlays/dev`
