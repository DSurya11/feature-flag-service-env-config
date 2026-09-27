#!/usr/bin/env bash
# Validate everything Argo CD would apply: render every Kustomize overlay and check the output,
# plus the plain manifests, against Kubernetes + CRD JSON schemas. Run by CI on every push/PR
# (required check on main) and locally: ./scripts/validate.sh  (needs kubectl + kubeconform)
set -euo pipefail
cd "$(dirname "$0")/.."

K8S_VERSION="${K8S_VERSION:-1.35.0}"   # EKS version (idp-infra/30-cluster)
KC=(kubeconform -strict -summary -output text -kubernetes-version "$K8S_VERSION"
    -schema-location default
    # CRDs (Argo CD Application, ExternalSecret, ClusterSecretStore, Kyverno ...)
    -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json')

fail=0
# Deployable roots: overlays and standalone kustomizations (bases are covered via overlays).
for dir in $(find apps platform -name kustomization.yaml -not -path '*/base/*' -printf '%h\n' | sort); do
  echo "==> $dir"
  kubectl kustomize "$dir" | "${KC[@]}" - || fail=1
done
# Plain manifests (not under a kustomization).
for f in platform/argocd-apps/*.yaml platform/kyverno/*.yaml; do
  echo "==> $f"
  "${KC[@]}" "$f" || fail=1
done
exit $fail
