# knowledge-library Specification

## Purpose

Lets the athlete give the chat agent their own coaching references — imported Markdown documents, managed in the app and searched alongside the bundled reference — without rebuilding the app and without affecting plan generation.

## Requirements

### Requirement: Import Markdown documents
The system SHALL let the athlete pick one or more Markdown or plain-text files from the device and import each as a document, split into sections at level-1 `#` headings. A file with no level-1 heading SHALL become a single section titled after the file name. The document title SHALL be the file's first level-1 heading, or the file name when there is none.

#### Scenario: Multi-section file
- **WHEN** the athlete imports `swim-css.md` containing `# CSS test`, `# Threshold sets` and `# Drills`
- **THEN** the library lists one document with three sections, and the agent can find each section

#### Scenario: File without headings
- **WHEN** the athlete imports `taper-notes.txt` with no `#` heading
- **THEN** it is stored as one section titled "taper-notes"

#### Scenario: Re-importing the same file name
- **WHEN** a file with the same name as an existing document is imported
- **THEN** the athlete is asked whether to replace the existing document or keep both

### Requirement: Import is agent-only
Imported documents SHALL NOT change plan rules, goals or session templates. Fenced `okf-rules`, `okf-goal` and `okf-template` blocks in an imported file SHALL be dropped from the stored text, and the import result SHALL say how many were ignored.

#### Scenario: File with an okf-template block
- **WHEN** an imported file contains one `okf-template` block and prose
- **THEN** the prose is stored, the block is not, the plan engine's templates are unchanged, and the import result says one structured block was ignored

### Requirement: Rejecting unusable files
The system SHALL reject a file that is larger than the size cap, is not valid UTF-8 text, or contains no text, and SHALL show the reason. A rejected file SHALL leave the library unchanged.

#### Scenario: Oversized file
- **WHEN** the athlete picks a file above the size cap
- **THEN** nothing is imported and the message names the cap

### Requirement: Managing the library
The library screen SHALL list every imported document with its title, source file name, section count and import date, and SHALL let the athlete turn a document off or on and delete it after confirmation. A disabled document SHALL stay stored but SHALL NOT be searched.

#### Scenario: Disabling a document
- **WHEN** the athlete turns off "Swim CSS guide"
- **THEN** the agent's guidance search no longer returns its sections, and turning it on again restores them without re-importing

#### Scenario: Deleting a document
- **WHEN** the athlete confirms deletion of a document
- **THEN** it and its sections are removed from local storage

### Requirement: Agent search across documents
`get_training_guidance` SHALL search the bundled reference (when installed) and every enabled imported document, score each section on its heading and body, return the best matches with the title of the document each came from, and list the titles of the remaining matching sections. With an empty topic it SHALL list the available sections grouped by document.

#### Scenario: Topic matched in an imported document
- **WHEN** the agent looks up "threshold swim sets" and only the imported swim guide covers it
- **THEN** the tool returns that section with its document title, and the agent's answer names the document

#### Scenario: Many matches
- **WHEN** a topic matches more sections than the result limit
- **THEN** the best matches are returned in full and the others by title only, so the agent can ask for one by name

#### Scenario: Nothing installed or imported
- **WHEN** there is no bundled reference and no enabled imported document
- **THEN** the tool reports that no reference is available, as today, and mentions that documents can be imported under More

### Requirement: Platform availability
The knowledge library SHALL be available on Android and Windows. Where local storage is unavailable (web), the library entry SHALL be hidden and the agent SHALL use only the bundled reference.

#### Scenario: Web build
- **WHEN** the app runs on web
- **THEN** More shows no knowledge library entry and guidance search works from the bundled reference alone
