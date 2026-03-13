# Onboarding Questionnaire

<!-- Agent instructions: Read this file when the user types "setup". Ask ALL questions
     in a single conversational pass. The user should be able to answer everything in one
     message. Collect answers. Replace placeholders across the specified files. After all
     replacements, verify no {{PLACEHOLDER}} patterns remain in the workspace. -->

Configure your research pipeline with your preferences.

---

### Q1: What citation format should your research use?

- Placeholder: `{{CITATION_STYLE}}`
- Files: `brand-vault.md`, `stages/05-output/references/output-templates/report-template.md`
- Type: selection
- Options: APA, MLA, Chicago, IEEE, Harvard
- Default: APA

### Q2: How formal should your research writing be?

- Placeholder: `{{FORMALITY_LEVEL}}`
- Files: `brand-vault.md`
- Type: selection
- Options: formal, semi-formal, conversational
- Default: formal
- Derived: If "conversational", set `{{FIRST_PERSON_OK}}` to "yes"

### Q3: Can you use first-person in your research writing?

- Placeholder: `{{FIRST_PERSON_OK}}`
- Files: `brand-vault.md`
- Type: selection
- Options: yes, no
- Default: no

### Q4: Do you prefer deep, focused research or broad, comprehensive coverage?

- Placeholder: `{{DEPTH_VS_BREADTH}}`
- Files: `brand-vault.md`
- Type: selection
- Options: deep, balanced, broad
- Default: balanced

### Q5: What credibility level do you require for sources?

- Placeholder: `{{SOURCE_CREDIBILITY_THRESHOLD}}`
- Files: `brand-vault.md`
- Type: selection
- Options: peer-reviewed only, peer-reviewed preferred, any credible source, open to all
- Default: peer-reviewed preferred

### Q6: How recent should your sources be?

- Placeholder: `{{RECENCY_PREFERENCE}}`
- Files: `brand-vault.md`
- Type: selection
- Options: last 1 year, last 3 years, last 5 years, any date
- Default: last 5 years

### Q7: What is the minimum number of sources you want per research question?

- Placeholder: `{{MIN_SOURCES_PER_QUESTION}}`
- Files: `brand-vault.md`
- Type: free text
- Default: 3

### Q8: What is your default output format?

- Placeholder: `{{DEFAULT_OUTPUT_FORMAT}}`
- Files: `brand-vault.md`
- Type: selection
- Options: report, dataset, documentation
- Default: report

### Q9: Should sections be numbered?

- Placeholder: `{{SECTION_STYLE}}`
- Files: `brand-vault.md`
- Type: selection
- Options: numbered, unnumbered
- Default: numbered

### Q10: Should reports include an executive summary?

- Placeholder: `{{INCLUDE_EXECUTIVE_SUMMARY}}`
- Files: `brand-vault.md`, `stages/05-output/references/output-templates/report-template.md`
- Type: selection
- Options: yes, no
- Default: yes
- Conditional: If "no", remove the `{{?INCLUDE_EXECUTIVE_SUMMARY}}` section from report-template.md

### Q11: Should reports include a methodology appendix?

- Placeholder: `{{INCLUDE_METHODOLOGY_APPENDIX}}`
- Files: `brand-vault.md`, `stages/05-output/references/output-templates/report-template.md`
- Type: selection
- Options: yes, no
- Default: yes
- Conditional: If "no", remove the `{{?INCLUDE_METHODOLOGY_APPENDIX}}` section from report-template.md

### Q12: Should research outputs be auto-published to Google Drive?

- Placeholder: `{{AUTO_PUBLISH}}`
- Files: `brand-vault.md`
- Type: selection
- Options: yes, no
- Default: no
- Conditional: If "no", remove the 06-publish stage from CLAUDE.md folder map and routing
- Note: Requires `@googleworkspace/cli` to be installed and authenticated

---

## After Onboarding

Your research pipeline is configured. Here is what was set:

- Citation style: {{CITATION_STYLE}}
- Formality: {{FORMALITY_LEVEL}}
- Source standards: {{SOURCE_CREDIBILITY_THRESHOLD}}, {{RECENCY_PREFERENCE}}
- Default output: {{DEFAULT_OUTPUT_FORMAT}}
- Auto-publish: {{AUTO_PUBLISH}}

To start research, go to `stages/01-scoping/CONTEXT.md` and provide your research question or topic.

After all replacements, scan the entire workspace for remaining `{{` patterns. If any remain, ask for the missing info.
