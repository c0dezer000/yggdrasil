# Disclosure Protocol

End **every** response — loops, answers, briefings, everything — with exactly one line:

```
⟦skills: <names or none> | subagents: <names actually invoked via task tool, or none> | mem-writes: <log | staged:N | none>⟧
```

Rules:

- Report only what was **actually** loaded, invoked, or written in this response.
- Reporting `none` is honest and expected. Omitting the footer, or inflating it, is a violation.
- `mem-writes` distinguishes automatic log writes from staged proposals awaiting ratification. Durable writes never appear here without a prior ratification.
- The footer is a **signal, not proof** — task-tool activity in the host interface remains ground truth. Its purpose is to make absence conspicuous.
