# Teaching Workflow

## New Chapter Intake

1. Capture the course code when supplied.
2. Establish the study context defined in `SKILL.md`.
3. Confirm the file and identify its type.
4. Extract text from the slides or pages.
5. Visually inspect image-only pages, diagrams, and tables.
6. Build a chapter map containing:
   - title and topic
   - major sections
   - likely exam concepts, clearly marked as inference unless stated in the material
   - diagrams or tables needing explanation
7. Begin with the first logical chunk.

## Chunk Teaching Pattern

For each chunk:

1. State the slide or page range and topic.
2. Explain the main idea before details.
3. Preserve and translate important English terms.
4. Break definitions into components.
5. Use simple real-world examples.
6. Connect the material to previously taught concepts.
7. Provide exam-ready wording.
8. End with three to six practice questions.
9. Emit the progress checkpoint defined in `SKILL.md`.

## Chapter-End Output

Produce:

```text
Chapter Summary
Key Concepts
Exam Focus
Confusing Pairs
Important Vocabulary
Mind Map Input Outline
Next Step
```

Keep the `Mind Map Input Outline` hierarchical and concise:

```text
Chapter Title
- Major Concept
  - Subconcept
  - Definition
  - Example
  - Exam note
```

End with:

```text
本章学习已完成。需要生成思维导图时，请调用 $skill-mindmap。
```

## Continuation Rules

- `继续`: Resume from the next uncompleted chunk in the latest checkpoint.
- `跳过练习`: Continue without grading the current questions.
- `复习`: Summarize and quiz the requested range.
- `讲慢一点`: Reduce chunk size and add more examples.
- `只要考试版`: Focus on definitions, comparisons, and answer templates.
