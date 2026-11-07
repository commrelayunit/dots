# services/

Future home for independently managed systemd units:

- `user/`   → `~/.config/systemd/user/`
- `system/` → `/etc/systemd/system/`

**Nothing here is deployed, enabled, or started by `install.sh`.** Every service
is a separate, explicit future opt-in stage. See `docs/MIGRATION_PLAN.md` §5
for the candidate inventory and safety notes.
