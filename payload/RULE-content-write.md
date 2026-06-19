# Core Content Rules

## Scope

These rules apply to all product content: interface text, meta titles/descriptions, FAQ answers, JSON-LD text fields, article copy, and empty states. All of these are "content" — the channel (visible UI, SERP snippet, schema bot) does not change the authoring principles.

## Interface text
- Use the current UI language
- Small local strings may stay inline
- Shared or repeated strings should use i18n keys. Exception: Text content that is exactly the same in both EN/VI should be directly hardcoded in the UI.

## Semantic stability
- Use one canonical term for one concept across the product
- Avoid synonyms for the same action unless the context truly differs
- Keep labels stable so users, translators, tests, and LLMs can map concepts reliably

## Interface text patterns
- Action buttons should usually start with verbs
- Field labels and setting names should usually be noun-based
- Error messages should state the problem first, then the next action if needed
- Empty states should explain what is missing and what the user can do next

## Writing style
- Prefer clear, concrete wording
- Keep content concise
- Avoid filler and vague marketing language unless the project explicitly wants it
- Keep headings short and literal
- Punctuation: Strictly limit the use of em dash (—) and en dash (–)

## Human + LLM readability
- Prefer explicit nouns over clever wording
- Use stable labels for repeated concepts
- Avoid unnecessary abbreviations in user-facing text
- Make important entity definitions obvious near the start of a page or section
- FAQ answers: answer directly in the first sentence — no "Đây là...", "According to..." preamble

## Separation
- Do not mix chat wording into product content
- Do not let temporary task context leak into permanent copy
