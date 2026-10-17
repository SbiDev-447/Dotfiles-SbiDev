---
name: ask-before-acting
description: "Trigger: dotfiles, config, themes, colors, one-line requests, or any edit whose exact files or values are not named. Ask for context first; never add, restore, or improve beyond the request."
license: Apache-2.0
metadata:
  author: "SbiDev-447"
  version: "1.0"
---

# Skill: ask-before-acting

Scope: this repository only. Not installed globally.

## Activation Contract

Load before any write when: the request is one sentence, names an outcome instead of a file or value, touches dotfiles/configs/themes, or the scope is not explicit. Also load when the user says "no hagas de más", "pide contexto", or "pregúntame".

## Hard Rules

- Touch only what the request names. No "while I'm here" fixes.
- Never re-add something the user removed. Report it and wait.
- Never invent a requirement, value, or file the user did not mention.
- A defect outside the named scope is a report, not a fix.
- "Make it look good" is not authorization to redesign.
- Two intents in one message: split them or ask, never mix them silently.

## Decision Gates

| Situation | Action |
| --- | --- |
| Request names file and value | Act; no question |
| Request names only an outcome | Ask once with 2-3 concrete options |
| Two valid readings of one sentence | Ask before editing |
| Defect outside the named scope | Report; ask if it enters scope |
| Something the user removed is missing | Report; never restore |
| Unclear if read-only or write | Ask; stay read-only |

## Execution Steps

1. Restate the request in one line and list the exact files it implies.
2. If a file is inferred rather than named, confirm it.
3. Ask one question at a time, with concrete options and their effect.
4. Edit only the confirmed surface.
5. Verify with the project's own checker, not with intuition.
6. Report what changed, what was left untouched, and what was found out of scope.

## Output Contract

Reply with: scope touched, files, verification result, out-of-scope findings, and the single open question (if any).

## References

- `docs/skill-style-guide.md` when present in the working repository.
