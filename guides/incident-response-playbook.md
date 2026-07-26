# Incident-Response Playbook

> **Must exist before any communication channel goes live.** (GUIDE.md §636-638)
> Dry-run walkthrough before the first message arrives.

## Phases

### 1. ISOLATE — stop the bleeding

| Action | Command / Method | Verification |
|--------|-----------------|--------------|
| Disconnect the compromised channel | <specific: e.g., close port, disable service, revoke key> | Confirm no further messages arrive |
| Block outbound communication | <specific: e.g., firewall rule, kill switch> | `curl` or equivalent fails |
| Preserve logs and state | Copy `seed/memory/log/`, `seed/memory/provenance.md`, host logs | Files copied to safe location, originals untouched |
| Revoke any active session tokens | <specific method> | Token rotation confirmed |

### 2. ASSESS — understand what happened

| Question | Evidence to collect |
|----------|-------------------|
| What was the entry vector? | Logs, network traces, the triggering message |
| Was any durable memory modified? | `git diff --name-only -- seed/memory/` — look for changes outside log/ |
| Was any data exfiltrated? | Check outbound channel logs, git push history |
| Were any secrets exposed? | Check `provenance.md` for secret references, check env vars |
| Which conformance assertions failed? | Run `ygg verify` and compare against last known pass |

### 3. REMEDIATE — fix and fortify

| Priority | Action | Evidence of completion |
|----------|--------|----------------------|
| 1 | Patch the entry vector | <specific fix> |
| 2 | Rotate any exposed credentials | All tokens, keys, passwords in scope |
| 3 | Restore any corrupted durable memory | From git checkout or last known-good backup |
| 4 | Add a conformance assertion that would catch this vector | Assertion ID and location |
| 5 | Update the playbook with lessons learned | This section updated |

### 4. RECORD — document for the ledger

Write a provenance.md entry with type `incident`:
```
YYYY-MM-DD · `incident` · <domain> · <one line summary> · evidence: <paths>
```

Also add a growth-ledger entry if the seed itself was changed.

---

## Pre-authorized actions (may do alone during incident)

- Disconnect the communication channel
- Preserve logs and state
- Run `ygg verify` and `ygg doctor` for diagnostics
- Read any file needed for assessment
- Stage proposals for durable memory corrections

## Actions that require gardener approval

- Any state-changing git operation (branch, push, revert)
- Modifying durable memory outside the airlock
- Rotating credentials or secrets
- Making constitutional changes

## Emergency contacts and procedures

<gardener to fill: escalation contacts, backup communication paths, fallback procedures>

---

## Dry-run checklist

- [ ] Isolation step practiced: channel disconnected within <time> target
- [ ] Assessment step practiced: root cause identified within <time> target
- [ ] Remediation step practiced: fix applied
- [ ] Recording step practiced: provenance entry written
- [ ] Playbook updated with dry-run findings
