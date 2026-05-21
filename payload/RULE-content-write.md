# Core Content Rules

## UI text
- Use the current UI language
- Small local strings may stay inline
- Shared or repeated strings should use i18n keys

## Semantic stability
- Use one canonical term for one concept across the product
- Avoid synonyms for the same action unless the context truly differs
- Keep labels stable so users, translators, tests, and LLMs can map concepts reliably

## UI copy patterns
- Action buttons should usually start with verbs
- Field labels and setting names should usually be noun-based
- Error messages should state the problem first, then the next action if needed
- Empty states should explain what is missing and what the user can do next

## Writing style
- Prefer clear, concrete wording
- Keep UI copy concise
- Avoid filler and vague marketing language unless the project explicitly wants it
- Keep headings short and literal

## Human + LLM readability
- Prefer explicit nouns over clever wording
- Use stable labels for repeated concepts
- Avoid unnecessary abbreviations in user-facing text
- Make important entity definitions obvious near the start of a page or section

## Separation
- Do not mix chat wording into product content
- Do not let temporary task context leak into permanent copy
