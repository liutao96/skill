# Suno Core Reference

## Working Model

Suno work has four control layers:

```text
purpose and scene
-> Style Prompt
-> Lyrics and structure tags
-> version review and iteration
```

Style Prompt controls the sound. Lyrics controls words, sections, and flow. Generation is probabilistic, so versioning matters.

## Style Prompt Formula

Use compact English, usually 20-45 words:

```text
mood + genre + vocal + instruments + rhythm/tempo + production + scene
```

Examples of control phrases:

```text
vocals start immediately, no intro
clear Mandarin pronunciation, articulate Chinese vocal
fast-paced, tight cadence, bouncy beat
instrumental, no vocals
original melody, no artist imitation
```

## Lyrics Field

Use structure tags when helpful:

```text
[Hook]
[Verse]
[Chorus]
[Bridge]
[Outro]
[End]
```

Short-video lyrics should be short, concrete, and easy to subtitle. Full songs can use verse/chorus development.

## Default Safety Boundaries

- Do not imitate a specific singer, song, melody, or protected work.
- Do not claim AI-generated music is a real human performance or a real animal voice.
- Do not copy paid course text; summarize and operationalize it.
- For commercial use, platform rules, account plan rights, upload policy, AI labeling, royalties, and copyright terms must be checked against current official rules.

## Short Video Versus Full Song

| Need | Preferred structure |
|---|---|
| Short video | 12-30 second hook, no intro, direct event, readable lyrics |
| BGM | instrumental, no vocals, supports scene without stealing attention |
| Full song | Verse/Chorus/Bridge, emotional progression, more complete arrangement |
| Revision | Preserve working parts and change only the failing layer |