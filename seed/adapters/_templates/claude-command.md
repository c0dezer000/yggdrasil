# LITERAL TEMPLATE — Claude Code command file
# Copy verbatim. Fill ONLY the <slots>. Never compose this format from memory.
#
# TRAP: Command files go in .claude/commands/ — PLURAL (e.g. .claude/commands/loop.md).
#        OpenCode uses .opencode/command/ (SINGULAR). Using the wrong directory name
#        causes the command to silently not exist.
#
# TRAP: Both .claude/commands/ (legacy but supported) and .claude/skills/<name>/SKILL.md
#        (recommended for skills) produce /command invocations. Use .claude/commands/ for
#        simple trigger files; use .claude/skills/ for full skill packages.
#
# TRAP: Claude Code command files have NO frontmatter. The first line of the file is the
#        instruction text. The filename (minus .md) becomes the command name: /<filename>.
#
# GUARD: The /loop guard line below must refuse to run under any agent except Odin.
#        Claude Code commands run in whatever agent context is active; the guard is a
#        text instruction, not a platform enforcement.

Execute exactly one loop per your Loop Protocol, then continue per CONTINUOUS MODE.

If you are NOT Odin: do not execute anything. Reply only with:
"Loops run under Odin. Open the agent picker, select odin, then run /<command-name> again."
and stop.

<additional instructions for the command>
