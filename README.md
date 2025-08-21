# 📋 Pipeline Templates Progress

This checklist tracks which GitLab pipeline templates have been completed and which still need to be created.

---

## ✅ Completed Pipeline Templates

- [x] **Secrets Detection Template** – runs secret scanning during dev pipelines
- [x] **Deploy Base Template** – registers GitLab environments, simulates deployments
- [x] **Trigger Downstream Template** – triggers dependent builds (fan-out/fan-in)
- [ ] **Add a job that exports the docker images for customer releases**

---

## ⏳ To-Do Pipeline Templates
- [ ] **Version Bump Template** – updates `VERSION` file and `CHANGELOG.md` during tag pipelines
- [ ] **Container Scan Template** – runs vulnerability scans on pushed images
- [ ] **Helm Deploy Template** – deploys into OpenShift/Kubernetes using Helm
- [ ] **Test Automation Template** – runs unit/integration tests before build
- [ ] **Release Promotion Template** – promotes artifacts across `dev → test → int → prod`
- [ ] **Dependency Update Template** – auto-bumps dependencies from a config file
- [ ] **Changelog Normalization Template** – enforces changelog format across repos
- [ ] **Docker Build Template** – builds container images with OCI-compliant labels
- [ ] **SonarQube Scan Template** – supports MR scans and main-branch analysis

---

## 🗂 Notes
- All templates should be modular and reusable across 40+ services.
- Rules should be centralized, with overrides possible at the service level.
- Dev and staging pipelines may include additional logging/scan steps.
