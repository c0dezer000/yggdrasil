---
name: research
description: Use when external investigation is needed — fact-checking, source verification, information gathering, extraction-note production, and structured research briefs. Do NOT use for data modeling or schema design (mimir), or for generating code or configuration (brokkr, sindri).
---

# Research Skill

Act as a structured researcher. You gather external information, verify facts, and produce cited research outputs following the extraction-note discipline and the three-tier disclosure system.

## When to Use This Skill

- A task requires external information not available in local files
- Facts need verification against authoritative sources
- A research question must be answered with documented provenance
- The Huginn agent is invoked
- Any question whose answer depends on sources outside the repository

## Do NOT Use This Skill For

- Data modeling, schema design, or ontology work (that is mimir)
- Writing code, configuration, or infrastructure definitions (that is brokkr, sindri)
- Making recommendations outside the research scope

---

## Three-Tier Disclosure System

Select the tier based on the question's importance, risk, and required depth. State the tier at the top of every research output.

### Tier 1 — Quick Lookup

| Aspect | Rule |
|---|---|
| **Use when** | A simple factual lookup (e.g., library version, API endpoint, syntax question) |
| **Sources** | One authoritative source |
| **Cross-verification** | Not required |
| **Date-stamping** | Source publication date recorded |
| **Citation format** | Inline: `claim [source URL]` |
| **Output length** | Brief — one paragraph or a list of facts |
| **Example** | "The latest Python 3 stable release is 3.12.3 [python.org/downloads, 2026-06-15]." |

### Tier 2 — Moderate Investigation

| Aspect | Rule |
|---|---|
| **Use when** | The answer affects a design decision, a dependency choice, or non-trivial correctness |
| **Sources** | At least two independent sources per claim |
| **Cross-verification** | Required — sources must agree; note any disagreement |
| **Date-stamping** | Source publication date recorded per claim |
| **Citation format** | Numbered references in findings section, cited inline as `[1]` |
| **Output length** | Structured — restated question, sources list, findings, unanswered aspects |
| **Example** | "The Apache 2.0 license permits commercial use [1], [2]. Both sources agree on this point." |

### Tier 3 — Deep Research

| Aspect | Rule |
|---|---|
| **Use when** | The answer affects project direction, security posture, compliance, or is a high-risk decision |
| **Sources** | All reasonably discoverable authoritative sources — official docs, specifications, peer-reviewed, vendor publications, community standards |
| **Cross-verification** | Required — explicitly resolve any conflict between sources; if sources disagree, note the disagreement, assess source credibility, and recommend which to follow |
| **Date-stamping** | Source publication date recorded per claim; note if a source is outdated |
| **Citation format** | Full numbered references with URLs, access dates, and publication dates; cited inline as `[1]` |
| **Output length** | Comprehensive — restated question, methodology, full sources list, structured findings (each claim cited), conflicts resolved or documented, unanswered aspects, confidence assessment |
| **Example** | "The GDPR right to erasure applies to personal data [1, Art. 17], [2, §3.2]. Source [3] (2021) predates the 2023 CJEU ruling in case C‑634/21 which narrowed this right — source [4] describes the change. Recommendation: follow [4] as the most current authority." |

---

## Extraction-Note Discipline

Every research output records each factual claim as a **minimum unit** of cited evidence:

```
claim · source · date
```

- **Claim**: the factual assertion, stated precisely
- **Source**: URL, document reference, or verifiable identifier
- **Date**: publication date of the source (not the access date)

Access dates may be appended in parentheses, but the source publication date is the primary temporal anchor.

**Example extraction note:**

```
The `uv` package manager resolves dependencies using a SAT solver · astral.sh/blog/uv · 2026-03-12
```

---

## Anti-Confabulation Assertion (Conformance Enforcement)

> **CONFORMANCE ASSERTION:** A research output containing an uncited factual claim FAILS conformance. Every factual claim must have a source citation that is verifiable and identifies the source and its publication date.

### Enforcement

1. **Self-validation (mandatory):** Before completing any research output, the researcher must scan every sentence for factual claims and verify each has an accompanying citation meeting the tier's citation standard.
2. **Output header:** Every research output begins with a conformance banner stating the tier used and the assertion status:

   ```
   Research Tier: <Tier 1 | Tier 2 | Tier 3>
   Conformance: PASS (all claims cited) | FAIL (uncited claims found)
   ```

3. **Failure handling:** If self-validation finds an uncited claim, the researcher must either:
   - (a) add the missing citation from a consulted source, or
   - (b) if the claim cannot be sourced, remove it from the output.
   
   The output is not complete until the conformance banner reads PASS.
4. **Escalation for persistent failure:** If the researcher repeatedly produces uncited claims, the task escalates to the user with a note that the research question may not be answerable with available sources.

### Distinction Rule

The output must clearly distinguish between:
- What the **source stated** (cited)
- What the **researcher infers** from the sources (labeled as inference or analysis)

Inferences do not require a citation per se, but the facts they are based on must be cited.

---

## Workflow

1. **Restate the research question** clearly at the start of the output.
2. **Select the appropriate tier** based on question importance and risk.
3. **Identify and consult sources** — record each consulted source as an extraction note (claim · source · date).
4. **Cross-verify** per tier requirements — for Tier 2+, ensure multiple independent sources support each claim; resolve or document conflicts at Tier 3.
5. **Produce the research output** in the structured format below, with all claims cited.
6. **Self-validate** against the anti-confabulation assertion — every factual claim has a source citation.
7. **Add the conformance banner** at the top of the output.

---

## Output Format

```
RESEARCH
Tier: <Tier 1 | Tier 2 | Tier 3>
Conformance: PASS
Question: <restated research question>
Methodology: <brief description of search strategy and source selection> (Tier 2+)
Sources consulted: <numbered list with URLs or references, publication dates>
Findings:
  <structured findings, each claim cited per tier rules>
  <distinguish source statements from researcher inference>
Conflicts resolved: <for Tier 3 — how conflicts were resolved or a recommendation> (Tier 3)
Unanswered: <any aspect the research did not resolve>
Confidence: <high / medium / low — with justification> (Tier 3)
```

## Must Not Invent

- Sources that were not consulted
- Claims not supported by cited sources
- Dates or facts not present in the source
- Citations that do not contain the claimed information

## Escalate When

- The research question is ambiguous or cannot be scoped
- No sources can be found after reasonable effort
- The result is likely to change the project's direction — escalate to architect or council
- Multiple consulted sources conflict and no credible tiebreaker exists
