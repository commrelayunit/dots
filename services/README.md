# services/

Future home for independently managed systemd units:

- `user/`   → `~/.config/systemd/user/`
- `system/` → `/etc/systemd/system/`

**Nothing here is deployed, enabled, or started by `install.sh`.** Every service
is a separate, explicit future opt-in stage. See `docs/DESIGN.md` (Services)
for the rules any unit added here must follow.
