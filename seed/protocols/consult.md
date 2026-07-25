# Consultation Protocol

For adopting a **new** project. For an existing codebase use `onboard.md`; both end in a filled project profile.

## Order of operations

1. **Reference intake first.** Ask for reference material before anything else: documents, mockups, specs, images, links. Images are extracted to text once; the extraction becomes the quotable reference, not the image.
2. **Derive before asking.** Read references and derive as many profile answers as possible; present them for one-tap confirmation. Never ask what a reference already answers.
3. **Ask what remains — batched.** At most 8 genuine questions, grouped by topic, each with 3–6 options carrying one-line trade-offs, exactly one marked **(Recommended)** with inline reasoning, plus two standing options on every question: **"Defer — decide in unit NN"** and **"Type your own answer."**
4. **Size the work.** Work-unit count and role roster proportional to the project. Over-scaffolding a small project is a failure, not thoroughness.
5. **Research the domain where it matters.** For regulated, financial, or safety-relevant domains, research constraints the gardener may not have stated — each finding marked with its source. **Unsourced legal or regulatory claims are prohibited**; an untraceable claim is presented as an open question instead.
6. **Present the plan.** Label every section **derived** or **asked**. Include scope and explicit non-scope, work units with done-conditions, role roster, high-stakes register, canonical documents, validation method, quality bar.
7. **Gate 1.** Ask the explicit approval question. Ambiguous acknowledgement is not approval. "Skip the plan and just build" is refused and redirected.
8. **Gate 2.** Present names for confirmation. "Keep defaults" is a valid explicit answer.
9. **Create**, then validate: no placeholders, every task has a done-condition, every roster role has a charter, configs pass the host's own loader.
10. **Stop and instruct a restart** — generated roles and commands register at host startup.

## Canonical document set (proposed per project)

Overview · Requirements · Architecture · **Process flows** · UI/UX and design system · Data model · Interfaces · Validation plan · Deployment · Decision record · Work-unit index.

**Process flows are not optional.** Entities and screens are nouns; flows are verbs — actor, trigger, steps, state transitions, decision points, error paths, and where high-stakes rules fire. Systems break at handoffs nobody drew.
