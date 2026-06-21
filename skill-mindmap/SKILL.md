---
name: skill-mindmap
description: Generate an offline Markmap mind map from a chapter completed through the skill-study workflow. Use when the user invokes $skill-mindmap with a chapter name or asks to convert a previously completed study framework into matching Markdown and self-contained HTML files. Require completed study context for the requested chapter.
---

# Skill Mindmap

Convert a completed `$skill-study` chapter framework into concise Markdown and a self-contained offline Markmap HTML file.

## Invocation

Accept one chapter argument:

```text
$skill-mindmap chap3
```

Normalize an optional `.md` suffix and validate the resulting name against `^[A-Za-z0-9_-]+$`. Reject absolute paths, path separators, `..`, and missing arguments.

## Study Prerequisite

Confirm that the current conversation contains a completed knowledge framework matching the requested chapter. It should include the chapter structure, key concepts, exam focus, confusing pairs, vocabulary, and relevant examples.

If matching context is absent, stop and respond:

```text
No completed study context was found for <chapter>.
Complete the matching chapter with $skill-study first.
```

Do not build a mind map from unrelated material or invent missing chapter content.

## Build The Markdown

Create `<chapter>.md` in the active workspace from the completed framework. Do not mechanically copy slide text.

Use this structure:

```markdown
---
markmap:
  colorFreezeLevel: 2
  initialExpandLevel: 3
  maxWidth: 280
---

# Chapter title

## Major topic

### Subtopic

- Definition
- Key point
- Example
- Exam note
```

Apply these rules:

- Keep one concept per node.
- Preserve important English technical terms.
- Use short phrases instead of lecture paragraphs.
- Include major processes, classifications, relationships, examples, and exam distinctions.
- Put confusing pairs and exam-ready distinctions in dedicated branches.
- Keep the source lecture material primary.
- Inspect an existing `<chapter>.md` before replacing it and preserve relevant user edits.

## Generate The Offline Mind Map

Run `scripts/generate_mindmap.ps1` after the Markdown file is ready.

If Node.js is not on `PATH`, call `codex_app.load_workspace_dependencies` and pass the returned Node executable through `-NodePath`.

```powershell
& '<powershell-path>' `
  -NoProfile `
  -ExecutionPolicy Bypass `
  -File '<skill-dir>\scripts\generate_mindmap.ps1' `
  -Chapter chap3 `
  -Workspace '<workspace>' `
  -NodePath '<bundled-node-path>'
```

The script searches the workspace for a local `markmap-cli`, runs it with `--offline --no-open`, and writes `<chapter>.html` beside the Markdown file.

Never install or download Markmap unless explicitly asked. When no local CLI exists, report the checked locations and explain that `markmap-cli` must be provided locally.

## Verify And Deliver

Before reporting success, require:

- `<chapter>.md` exists and contains the chapter title.
- `<chapter>.html` exists and is non-empty.
- The HTML contains Markmap initialization and an SVG container.
- The HTML contains no external HTTP or HTTPS script sources.
- The major framework branches appear in the output.

Return clickable paths to both files and state that the HTML is self-contained for offline use.
