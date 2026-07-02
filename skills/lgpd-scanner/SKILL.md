---
name: lgpd-scanner
description: Use when scanning a project for LGPD/GDPR compliance, identifying personal data processing, data flows, consent mechanisms, data subject rights, and privacy controls. Activates on "LGPD", "GDPR", "privacidade", "compliance", "dados pessoais", "data privacy". Expects scanner-output.json as input. Use ONLY for privacy/compliance scanning; do NOT use for business rules or documentation generation.
---

# LGPD Compliance Scanner

Scan the project for personal data processing and LGPD compliance. Requires `scanner-output.json` in the output directory.

## Output directory

All files under **`/mnt/d/Opencode/{project-name}/`** (create it if it doesn't exist).

## Input

Read `/mnt/d/Opencode/{project-name}/scanner-output.json` for project structure context.

## Output — `/mnt/d/Opencode/{project-name}/lgpd-report.json`

```json
{
  "projectName": "...",
  "personalDataInventory": [
    {
      "category": "Direct | Sensitive | Financial | Digital",
      "dataType": "name, CPF, email, ...",
      "collectedWhere": "...",
      "purpose": "...",
      "legalBasis": "Art. 7 LGPD - ...",
      "retention": "...",
      "sourceFile": "path/to/file:line"
    }
  ],
  "processingPoints": {
    "collection": ["forms", "third-party APIs", "..."],
    "storage": ["database", "logs", "cloud", "..."],
    "sharing": ["integrations", "partners", "..."],
    "deletion": ["anonymization", "cascade delete", "..."]
  },
  "complianceStatus": {
    "consentMechanisms": true,
    "privacyPolicy": true,
    "dataSubjectRequestEndpoints": true,
    "dpoContact": false,
    "encryptionAtRest": true,
    "encryptionInTransit": true,
    "accessControl": true,
    "auditLogs": false
  },
  "dataSubjectRights": [
    {"right": "Access (Art. 9, 19)", "implemented": true, "mechanism": "GET /api/user/data"},
    {"right": "Deletion (Art. 18 VI)", "implemented": false, "mechanism": null}
  ],
  "risks": [
    "Hardcoded credentials in config/database.yml:12",
    "Personal data logged in service/audit.ts:45"
  ]
}
```

## Workflow

1. Extract project name from target path: `basename "$1"`
2. Ensure output dir exists: `mkdir -p "/mnt/d/Opencode/{project-name}"`
3. Load `/mnt/d/Opencode/{project-name}/scanner-output.json`
4. Search original project code for personal data patterns (direct identifiers, sensitive data, financial data, digital identifiers)
5. Map processing points: collection, storage, sharing, retention, deletion
6. Identify compliance indicators: consent, privacy policy, DPO, encryption, access control, audit logs
7. Check data subject rights implementation (access, correction, deletion, portability, consent withdrawal)
8. Flag risks: hardcoded secrets, personal data in logs, excessive API exposure
9. For each finding, cite relevant LGPD article
10. Save to `/mnt/d/Opencode/{project-name}/lgpd-report.json`
