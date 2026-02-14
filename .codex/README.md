# PMOVES-Wealth Codex Home

Codex entrypoint for PMOVES financial workflows (renamed from PMOVES-Firefly-iii).

## Start Here

1. Install PMOVES Codex profile/config:
   - `make -C ../pmoves codex-config`
2. Review PMOVES operator docs:
   - `../pmoves/docs/AGENTS/CODEX_OPERATOR_HOME.md`
3. Validate finance service paths used by PMOVES:
   - `curl http://localhost:8082/health`
   - `curl http://localhost:8082/api/v1/about`

## PMOVES alignment

- Wealth service powers PMOVES finance integrations and agent flows.
- Keep wealth runbooks and automation aligned with PMOVES n8n and Supabase docs.
